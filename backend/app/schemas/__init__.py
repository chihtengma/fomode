"""
Schemas Package

Exports all Pydantic schemas for easy importing.
"""

# Goal Schemas
# FocusSession schemas
from app.schemas.focus_session import (
    FocusSession,
    FocusSessionBase,
    FocusSessionCreate,
    FocusSessionEnd,
    FocusSessionList,
    FocusSessionUpdate,
    FocusStats,
)
from app.schemas.goal import Goal, GoalBase, GoalCreate, GoalList, GoalUpdate

# UsageLog schemas
from app.schemas.usage import (
    AppUsageSummary,
    UsageLog,
    UsageLogBase,
    UsageLogCreate,
    UsageStats,
)

# Export all schemas
__all__ = [
    # Goal
    "GoalBase",
    "GoalCreate",
    "GoalUpdate",
    "Goal",
    "GoalList",
    # UsageLog
    "UsageLogBase",
    "UsageLogCreate",
    "UsageLog",
    "UsageStats",
    "AppUsageSummary",
    # FocusSession
    "FocusSessionBase",
    "FocusSessionCreate",
    "FocusSessionEnd",
    "FocusSessionUpdate",
    "FocusSession",
    "FocusStats",
    "FocusSessionList",
]
