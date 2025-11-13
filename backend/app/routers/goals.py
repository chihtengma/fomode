"""
Goals Router - API endpoints for managing daily goals.

This router handles all CRUD operations for goals:
    - Create new goal
    - List all goals
    - Get specific goal
    - Update goal (mark complete, edit title/description)
    - Delete goal
"""

from datetime import datetime, timezone
from typing import Any, Sequence

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Query, Session

from app.database import get_db
from app.models.goal import Goal as GoalModel
from app.schemas.goal import Goal as GoalSchema
from app.schemas.goal import GoalCreate, GoalList, GoalUpdate

# Create router instance
# prefix="/goals" means all routes will be prefixed with /goals
# tags=['goals'] groups these endpoints in the API documentation
router = APIRouter(prefix="/goals", tags=["goals"])


# ============================================================
# Utility Helper
# ============================================================


def get_goal_or_404(db: Session, goal_id: int) -> GoalModel:
    """Fetch a goal byt ID or raise 404."""
    goal: GoalModel | None = (
        db.query(GoalModel)
        .filter(GoalModel.id == goal_id, GoalModel.user_id == 1)
        .first()
    )

    if goal is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Goal with id {goal_id} not found",
        )

    return goal


# ============================================================
# Create Goal
# ============================================================


@router.post(path="/", response_model=GoalSchema, status_code=status.HTTP_201_CREATED)
async def create_goal(
    goal: GoalCreate, db: Session = Depends(dependency=get_db)
) -> GoalModel:
    """Create a new goal."""
    db_goal: GoalModel = GoalModel(
        **goal.model_dump(),
        user_id=1,  # Hardcoded for MVP until authentication
    )

    db.add(instance=db_goal)
    db.commit()
    db.refresh(instance=db_goal)

    return db_goal


# ============================================================
# List Goals
# ============================================================


@router.get(path="/", response_model=GoalList)
async def list_goals(
    db: Session = Depends(dependency=get_db),
    skip: int = 0,
    limit: int = 100,
    completed: bool | None = None,
) -> GoalList:
    """List all goals with optional filtering."""
    query: Query[GoalModel] = db.query(GoalModel).filter(GoalModel.user_id == 1)

    if completed is not None:
        query = query.filter(GoalModel.completed == completed)

    total: int = query.count()
    goals: Sequence[GoalModel] = query.offset(offset=skip).limit(limit).all()

    return GoalList(goals=goals, total=total)


# ============================================================
# Get Goal By ID
# ============================================================


@router.get(path="/{goal_id}", response_model=GoalSchema)
async def get_goal(goal_id: int, db: Session = Depends(dependency=get_db)) -> GoalModel:
    """Get a specific goal by ID."""
    return get_goal_or_404(db, goal_id)


# ============================================================
# Update Goal
# ============================================================


@router.put(path="/{goal_id}", response_model=GoalSchema)
async def update_goal(
    goal_id: int,
    goal_update: GoalUpdate,
    db: Session = Depends(dependency=get_db),
) -> GoalModel:
    """Update an existing goal."""
    goal: GoalModel | None = get_goal_or_404(db, goal_id)

    update_data: dict[str, Any] = goal_update.model_dump(exclude_unset=True)

    for field, value in update_data.items():
        setattr(goal, field, value)

    # update timestamp if your model supports it
    goal.updated_at = datetime.now(tz=timezone.utc)

    db.commit()
    db.refresh(instance=goal)

    return goal


# ============================================================
# Delete Goal
# ============================================================


@router.delete(path="/{goal_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_goal(goal_id: int, db: Session = Depends(dependency=get_db)) -> None:
    """Delete a goal."""
    goal: GoalModel | None = get_goal_or_404(db, goal_id)

    db.delete(instance=goal)
    db.commit()

    return None


# ============================================================
# Mark Goal Complete
# ============================================================


@router.post(path="/{goal_id}/complete", response_model=GoalSchema)
async def complete_goal(
    goal_id: int, db: Session = Depends(dependency=get_db)
) -> GoalModel:
    """Mark a goal as complete."""
    goal: GoalModel | None = get_goal_or_404(db, goal_id)

    goal.completed = True
    goal.updated_at = datetime.now(tz=timezone.utc)

    db.commit()
    db.refresh(instance=goal)

    return goal


# ============================================================
# Today's Goals
# ============================================================


@router.get(path="/today/list", response_model=GoalList)
async def get_todays_goals(db: Session = Depends(dependency=get_db)) -> GoalList:
    """Get today's goals."""
    today_start: datetime = datetime.now(tz=timezone.utc).replace(
        hour=0, minute=0, second=0, microsecond=0
    )

    goals: Sequence[GoalModel] = (
        db.query(GoalModel)
        .filter(
            GoalModel.user_id == 1,
            GoalModel.created_at >= today_start,
        )
        .all()
    )

    return GoalList(goals=goals, total=len(goals))
