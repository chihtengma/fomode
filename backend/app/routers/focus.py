"""
Focus Router
"""

from datetime import datetime, timedelta, timezone
from typing import Any, List, Optional

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Query, Session

from app.database import get_db
from app.models.focus_session import FocusSession as FocusSessionModel
from app.schemas.focus_session import FocusSession as FocusSessionSchema
from app.schemas.focus_session import (
    FocusSessionCreate,
    FocusSessionEnd,
    FocusSessionList,
    FocusSessionUpdate,
    FocusStats,
)

router: APIRouter = APIRouter(prefix="/focus", tags=["focus"])


# ---------------------------
# Auth / current user stub
# ---------------------------
def get_current_user_id() -> int:
    """TODO: Replacewith real authentication dependency."""
    return 1


# ---------------------------
# Helpers / Service layer
# ---------------------------


def get_session_or_404(db: Session, session_id: int, user_id: int) -> FocusSessionModel:
    """Fetch Session or raise a 404."""
    session: FocusSessionModel | None = (
        db.query(FocusSessionModel)
        .filter(
            FocusSessionModel.id == session_id, FocusSessionModel.user_id == user_id
        )
        .first()
    )
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Focus session {session_id} not found",
        )
    return session


def get_active_session_for_user(
    db: Session, user_id: int
) -> Optional[FocusSessionModel]:
    """Return active session (endtime is null) or None"""
    session: FocusSessionModel | None = (
        db.query(FocusSessionModel)
        .filter(
            FocusSessionModel.user_id == user_id,
            FocusSessionModel.end_time.is_(other=None),
        )
        .order_by(FocusSessionModel.start_time.desc())
        .first()
    )
    # Ensure duration is up-to-date for the active session
    if session:
        session.calculate_duration()
    return session


def create_focus_session(
    db: Session, user_id: int, interrupted: bool = False
) -> FocusSessionModel:
    """Create a new focus session"""
    active: FocusSessionModel | None = get_active_session_for_user(db, user_id)

    if active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Active focus session already exists (id: {active.id}. End it first.",
        )

    session: FocusSessionModel = FocusSessionModel(
        user_id=user_id, interrupted=interrupted
    )
    db.add(instance=session)
    return session


def end_focus_session_service(
    db: Session, session: FocusSessionModel, interrupted: Optional[bool] = None
) -> FocusSessionModel:
    """End a focus session and calculate duration."""
    if session.end_time is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail="Session already ended"
        )

    session.end_time = datetime.now(tz=timezone.utc)
    if interrupted is not None:
        session.interrupted = interrupted
    session.calculate_duration()
    return session


def update_focus_session_service(
    db: Session, session: FocusSessionModel, update_data: dict
) -> FocusSessionModel:
    """Partial update fields and recalc duration if end_time updated."""
    for field, value in update_data.items():
        setattr(session, field, value)

    if "end_time" in update_data:
        session.calculate_duration()

    return session


def delete_focus_session_service(db: Session, session: FocusSessionModel) -> None:
    """Delete a session (disllow deleting active sessions)."""
    if session.end_time is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete an active session. End it first.",
        )
    db.delete(instance=session)


def close_stale_sessions(db: Session, user_id: int, max_age_hours: int = 24) -> int:
    """
    Close sessions that were started but never ended and older than max_age_hours.
    Return number of closed sessions.
    """
    cutoff: datetime = datetime.now(tz=timezone.utc) - timedelta(hours=max_age_hours)
    stale_sessions: List[FocusSessionModel] = (
        db.query(FocusSessionModel)
        .filter(
            FocusSessionModel.user_id == user_id,
            FocusSessionModel.end_time.is_(other=None),
            FocusSessionModel.start_time < cutoff,
        )
        .all()
    )
    count = 0
    for session in stale_sessions:
        session.end_time = datetime.now(tz=timezone.utc)
        session.calculate_duration()
        count += 1
    return count


# ---------------------------
# Routes
# ---------------------------


@router.post(
    path="/start",
    response_model=FocusSessionSchema,
    status_code=status.HTTP_201_CREATED,
)
async def start_focus_session(
    session_data: FocusSessionCreate,
    db: Session = Depends(dependency=get_db),
    user_id: int = Depends(dependency=get_current_user_id),
) -> FocusSessionModel:
    """
    Start a new focus session. Only one active session allowed.
    """
    try:
        # Use a transaction boundary: commit if successfull, rollback on error
        session: FocusSessionModel = create_focus_session(
            db=db, user_id=user_id, interrupted=session_data.interrupted or False
        )
        db.commit()
        db.refresh(instance=session)
        return session
    except HTTPException:
        # re-raise user-level HTTP errors
        db.rollback()
        raise
    except SQLAlchemyError as err:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to start focus session",
        ) from err


@router.post(path="/end/{session_id}", response_model=FocusSessionSchema)
async def end_focus_session(
    session_id: int,
    session_data: FocusSessionEnd,
    db: Session = Depends(dependency=get_db),
    user_id: int = Depends(dependency=get_current_user_id),
) -> FocusSessionModel:
    """
    End an active focus session. Calculates duration and updates interrupted flag if provided.
    """
    try:
        session: FocusSessionModel = get_session_or_404(db, session_id, user_id)
        session = end_focus_session_service(
            db,
            session,
            interrupted=session_data.interrupted if session_data is not None else None,
        )
        db.commit()
        db.refresh(instance=session)
        return session
    except HTTPException:
        db.rollback()
        raise
    except SQLAlchemyError as err:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to end focus session",
        ) from err


@router.get(path="/active", response_model=Optional[FocusSessionSchema])
async def get_active_session(
    db: Session = Depends(dependency=get_db),
    user_id: int = Depends(dependency=get_current_user_id),
) -> FocusSessionModel | None:
    """Get the currently active focus session (or null)."""
    session: FocusSessionModel | None = get_active_session_for_user(db, user_id)
    return session


@router.get(path="/stats", response_model=FocusStats)
async def get_focus_stats(
    db: Session = Depends(dependency=get_db),
    user_id: int = Depends(dependency=get_current_user_id),
    date: Optional[str] = None,
) -> FocusStats:
    """
    Get daily focus stats for a specific date (YYYY-MM-DD) or today by default.
    Includes total sessions, total focus time, average/longest session, clean vs interrupted, and active session.
    """
    # parse date
    if date:
        try:
            target: datetime = datetime.strptime(date, "%Y-%m-%d").replace(
                tzinfo=timezone.utc
            )
        except ValueError:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid date format. Use YYYY-MM-DD",
            )
    else:
        target = datetime.now(timezone.utc)

    day_start: datetime = target.replace(hour=0, minute=0, second=0, microsecond=0)
    day_end: datetime = day_start + timedelta(days=1)

    # Query sessions in day range
    sessions: List[FocusSessionModel] = (
        db.query(FocusSessionModel)
        .filter(
            FocusSessionModel.user_id == user_id,
            FocusSessionModel.start_time >= day_start,
            FocusSessionModel.start_time < day_end,
        )
        .all()
    )

    total_sessions: int = len(sessions)
    completed: list[FocusSessionModel] = [s for s in sessions if s.end_time is not None]

    if completed:
        total_duration: int = sum(s.duration for s in completed)
        avg_duration: float = total_duration / len(completed)
        longest: int = max(s.duration for s in completed)
    else:
        total_duration = 0
        avg_duration = 0
        longest = 0

    clean: int = sum(1 for s in sessions if not s.interrupted)
    interrupted: int = sum(1 for s in sessions if s.interrupted)

    # active session may be outside today's start (but include if exists)
    active: FocusSessionModel | None = get_active_session_for_user(db, user_id)
    if active:
        # ensure duration reflects now
        active.calculate_duration()
        total_duration += active.duration

    return FocusStats(
        date=day_start.strftime(format="%Y-%m-%d"),
        total_sessions=total_sessions,
        total_duration_seconds=total_duration,
        total_duration_hours=total_duration / 3600.0,
        average_session_minutes=avg_duration / 60.0,
        longest_session_minutes=longest / 60.0,
        clean_sessions=clean,
        interrupted_sessions=interrupted,
        active_session=active,
    )


@router.get(path="/history", response_model=FocusSessionList)
async def get_focus_history(
    db: Session = Depends(dependency=get_db),
    user_id: int = Depends(dependency=get_current_user_id),
    skip: int = 0,
    limit: int = 50,
) -> FocusSessionList:
    """
    Get paginated session history ordered by start_time desc.
    Also returns total count and current active session (if any).
    """
    query: Query[FocusSessionModel] = db.query(FocusSessionModel).filter(
        FocusSessionModel.user_id == user_id
    )
    total: int = query.count()
    sessions: List[FocusSessionModel] = (
        query.order_by(FocusSessionModel.start_time.desc())
        .offset(offset=skip)
        .limit(limit)
        .all()
    )
    active: FocusSessionModel | None = get_active_session_for_user(db, user_id)
    # Make sure durations are accurate
    for s in sessions:
        if s.end_time is None:
            s.calculate_duration()
    return FocusSessionList(sessions=sessions, total=total, active_session=active)


@router.get(path="/{session_id}", response_model=FocusSessionSchema)
async def get_focus_session(
    session_id: int,
    db: Session = Depends(dependency=get_db),
    user_id: int = Depends(dependency=get_current_user_id),
) -> FocusSessionModel:
    """
    Get focus session by id (must belong to current user).
    """
    session: FocusSessionModel = get_session_or_404(db, session_id, user_id)
    # If active, recalc duration
    if session.end_time is None:
        session.calculate_duration()
    return session


@router.patch(path="/{session_id}", response_model=FocusSessionSchema)
async def update_focus_session(
    session_id: int,
    session_update: FocusSessionUpdate,
    db: Session = Depends(dependency=get_db),
    user_id: int = Depends(dependency=get_current_user_id),
) -> FocusSessionModel:
    """
    Partial update for a focus session.
    """
    try:
        session: FocusSessionModel = get_session_or_404(db, session_id, user_id)
        update_data: dict[str, Any] = session_update.model_dump(exclude_unset=True)
        session = update_focus_session_service(db, session, update_data)
        db.commit()
        db.refresh(instance=session)
        return session
    except HTTPException:
        db.rollback()
        raise
    except SQLAlchemyError as err:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update focus session",
        ) from err


@router.post(path="/cleanup/stale", response_model=dict)
async def cleanup_stale_sessions(
    max_age_hours: int = 24,
    db: Session = Depends(dependency=get_db),
    user_id: int = Depends(dependency=get_current_user_id),
) -> dict[str, int]:
    """
    Close stale active sessions older than `max_age_hours`.
    This endpoint is for manual trigger or can be called via a scheduled background job.
    """
    try:
        closed: int = close_stale_sessions(
            db, user_id=user_id, max_age_hours=max_age_hours
        )
        db.commit()
        return {"closed": closed}
    except SQLAlchemyError as err:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to cleanup stale sessions",
        ) from err


@router.delete(path="/{session_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_focus_session(
    session_id: int,
    db: Session = Depends(dependency=get_db),
    user_id: int = Depends(dependency=get_current_user_id),
) -> Response:
    """
    Delete a completed focus session. Cannot delete active sessions.
    """
    try:
        session: FocusSessionModel = get_session_or_404(db, session_id, user_id)
        delete_focus_session_service(db, session)
        db.commit()
        return Response(status_code=status.HTTP_204_NO_CONTENT)
    except HTTPException:
        db.rollback()
        raise
    except SQLAlchemyError as err:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to delete focus session",
        ) from err
