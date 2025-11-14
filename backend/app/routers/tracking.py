"""
Tracking Router - API endpoints for logging and analyzing app usage.

Improvements:
- Added helper functions for date ranges and user-based queries
- Removed repeated `.filter(user_id == 1)`
- Added reusable aggregation query
- Standardized all response types
- Improved readability and DRY
"""

from datetime import datetime, timedelta, timezone
from typing import Any, List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import Integer, UnaryExpression, func
from sqlalchemy.orm import Query, Session

from app.database import get_db
from app.models.usage import UsageLog as UsageLogModel
from app.schemas.usage import (
    AppUsageSummary,
    UsageLogCreate,
    UsageStats,
)
from app.schemas.usage import (
    UsageLog as UsageLogSchema,
)

router: APIRouter = APIRouter(prefix="/tracking", tags=["tracking"])


# ---------------------------------------------------------
# Helper: User ID placeholder (later replace with real auth)
# ---------------------------------------------------------
def get_current_user_id() -> int:
    return 1  # MVP hardcoded user


# ---------------------------------------------------------
# Helper: Date range for a full day
# ---------------------------------------------------------
def day_range(date: datetime) -> tuple[datetime, datetime]:
    start: datetime = date.replace(hour=0, minute=0, second=0, microsecond=0)
    return start, start + timedelta(days=1)


# ---------------------------------------------------------
# Helper: Base query for user's usage logs
# ---------------------------------------------------------
def user_logs(db: Session, user_id: int) -> Query:
    return db.query(UsageLogModel).filter(UsageLogModel.user_id == user_id)


# ---------------------------------------------------------
# Helper: Aggregation query for app stats
# ---------------------------------------------------------
def app_usage_aggregation(db: Session) -> Query:
    return db.query(
        UsageLogModel.app_name,
        UsageLogModel.package_name,
        func.sum(UsageLogModel.duration).label(name="total_duration"),
        func.count(expression=UsageLogModel.id).label(name="usage_count"),
        func.sum(func.cast(expression=UsageLogModel.intercepted, type_=Integer)).label(
            name="interception_count"
        ),
    )


# ---------------------------------------------------------


@router.post(
    path="/log", response_model=UsageLogSchema, status_code=status.HTTP_201_CREATED
)
async def log_usage(
    usage: UsageLogCreate,
    db: Session = Depends(dependency=get_db),
    user_id: int = Depends(dependency=get_current_user_id),
) -> UsageLogModel:
    """
    Log a usage event.
    """
    db_usage: UsageLogModel = UsageLogModel(**usage.model_dump(), user_id=user_id)
    db.add(instance=db_usage)
    db.commit()
    db.refresh(instance=db_usage)
    return db_usage


@router.get(path="/logs", response_model=List[UsageLogSchema])
async def get_usage_logs(
    db: Session = Depends(dependency=get_db),
    user_id: int = Depends(dependency=get_current_user_id),
    skip: int = 0,
    limit: int = 100,
    app_name: str | None = None,
    intercepted: bool | None = None,
    sort: str = "desc",
) -> List[UsageLogModel]:
    """
    Get usage logs with optional filtering + pagination + sorting.
    """

    query: Query[Any] = user_logs(db, user_id)

    if app_name:
        query = query.filter(UsageLogModel.app_name == app_name)

    if intercepted is not None:
        query = query.filter(UsageLogModel.intercepted == intercepted)

    order_expr: UnaryExpression[datetime] = (
        UsageLogModel.timestamp.asc()
        if sort == "asc"
        else UsageLogModel.timestamp.desc()
    )

    logs: List[Any] = query.order_by(order_expr).offset(offset=skip).limit(limit).all()
    return logs


@router.get(path="/stats", response_model=UsageStats)
async def get_usage_stats(
    db: Session = Depends(dependency=get_db),
    user_id: int = Depends(dependency=get_current_user_id),
    date: str | None = None,
    limit: int = 10,
) -> UsageStats:
    """
    Get daily usage statistics.
    """

    # Parse date
    if date:
        try:
            target_date: datetime = datetime.strptime(date, "%Y-%m-%d").replace(
                tzinfo=timezone.utc
            )
        except ValueError:
            raise HTTPException(
                status_code=400, detail="Invalid date format. Use YYYY-MM-DD."
            )
    else:
        target_date = datetime.now(tz=timezone.utc)

    day_start, day_end = day_range(date=target_date)

    logs: List[Any] = (
        user_logs(db, user_id)
        .filter(UsageLogModel.timestamp >= day_start)
        .filter(UsageLogModel.timestamp < day_end)
        .all()
    )

    total_seconds: int = sum(log.duration for log in logs)
    total_logs: int = len(logs)
    interceptions: int = sum(1 for log in logs if log.intercepted)

    # Get top apps for the day
    apps: List[Any] = (
        app_usage_aggregation(db)
        .filter(UsageLogModel.user_id == user_id)
        .filter(UsageLogModel.timestamp >= day_start)
        .filter(UsageLogModel.timestamp < day_end)
        .group_by(UsageLogModel.app_name, UsageLogModel.package_name)
        .order_by(func.sum(UsageLogModel.duration).desc())
        .limit(limit)
        .all()
    )

    most_used_apps: list[AppUsageSummary] = [
        AppUsageSummary(
            app_name=app.app_name,
            package_name=app.package_name,
            total_duration=app.total_duration or 0,
            usage_count=app.usage_count or 0,
            interception_count=app.interception_count or 0,
        )
        for app in apps
    ]

    return UsageStats(
        date=day_start.strftime(format="%Y-%m-%d"),
        total_duration_seconds=total_seconds,
        total_duration_minutes=total_seconds / 60.0,
        total_logs=total_logs,
        interception_count=interceptions,
        most_used_apps=most_used_apps,
    )


@router.get(path="/stats/weekly", response_model=List[UsageStats])
async def get_weekly_stats(
    db: Session = Depends(dependency=get_db),
    user_id: int = Depends(dependency=get_current_user_id),
) -> List[UsageStats]:
    """
    Get the last 7 days of usage stats.
    """
    stats: List[UsageStats] = []
    today: datetime = datetime.now(tz=timezone.utc).replace(
        hour=0, minute=0, second=0, microsecond=0
    )

    for offset in range(7):
        date: datetime = today - timedelta(days=offset)
        day_start, day_end = day_range(date)

        logs: List[Any] = (
            user_logs(db, user_id)
            .filter(UsageLogModel.timestamp >= day_start)
            .filter(UsageLogModel.timestamp < day_end)
            .all()
        )

        total_seconds: int = sum(log.duration for log in logs)
        interceptions: int = sum(1 for log in logs if log.intercepted)

        stats.append(
            UsageStats(
                date=day_start.strftime(format="%Y-%m-%d"),
                total_duration_seconds=total_seconds,
                total_duration_minutes=total_seconds / 60.0,
                total_logs=len(logs),
                interception_count=interceptions,
                most_used_apps=[],
            )
        )

    return stats


@router.get(path="/apps/top", response_model=List[AppUsageSummary])
async def get_top_apps(
    db: Session = Depends(dependency=get_db),
    user_id: int = Depends(dependency=get_current_user_id),
    days: int = 7,
    limit: int = 10,
) -> List[AppUsageSummary]:
    """
    Get most-used apps over the last N days.
    """

    start_date: datetime = datetime.now(tz=timezone.utc) - timedelta(days=days)

    apps: List[Any] = (
        app_usage_aggregation(db)
        .filter(UsageLogModel.user_id == user_id)
        .filter(UsageLogModel.timestamp >= start_date)
        .group_by(UsageLogModel.app_name, UsageLogModel.package_name)
        .order_by(func.sum(UsageLogModel.duration).desc())
        .limit(limit)
        .all()
    )

    return [
        AppUsageSummary(
            app_name=app.app_name,
            package_name=app.package_name,
            total_duration=app.total_duration or 0,
            usage_count=app.usage_count or 0,
            interception_count=app.interception_count or 0,
        )
        for app in apps
    ]


@router.delete(path="/logs/{log_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_usage_log(
    log_id: int,
    db: Session = Depends(dependency=get_db),
    user_id: int = Depends(dependency=get_current_user_id),
) -> None:
    """
    Delete a log entry.
    """
    log: Any | None = user_logs(db, user_id).filter(UsageLogModel.id == log_id).first()

    if not log:
        raise HTTPException(
            status_code=404, detail=f"Usage log with id {log_id} not found"
        )

    db.delete(instance=log)
    db.commit()
    return None
