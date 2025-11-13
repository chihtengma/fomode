"""
Goal Pydantic Schemas

These schemas handle:
1. Input validation (when creating/updating goals)
2. Output serialization (when returning goals to client)
3. Type hints for IDE autocomplete
4. Auto-generated API documentation

Pydantic vs SQLAlchemy:
- SQLAlchemy models = Database structure
- Pydantic schemas = API contracts (what goes in/out)
"""

from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, ConfigDict, Field

# ============================================
# Base Schema (Shared Fields)
# ============================================


class GoalBase(BaseModel):
    """
    Base schema with fields common to all goal operations.

    Other schemas inherit from this to avoid repeating fields.
    Only includes fields that users can set (not auto-generated ones).
    """

    # Goal title (required)
    title: str = Field(
        default=...,
        min_length=1,
        max_length=200,
        description="Short description of the goal",
        examples=["Solve 10 LeetCode problems", "Study Systen Design for 1 hour"],
    )

    # Goal description (Optional)
    description: Optional[str] = Field(
        default=None,
        max_length=100,
        description="Detailed description of the goal (optional)",
        examples=["Focus on arrays and strings", "Complete chater 1-3"],
    )


# ============================================
# Create Schema (Input for POST /goals)
# ============================================


class GoalCreate(GoalBase):
    """
    Schema for creating a new goal.

    Used when: POST /goals
    """

    pass


# ============================================
# Update Schema (Input for PUT /goals/{id})
# ============================================


class GoalUpdate(BaseModel):
    """
    Schema for updating an existing goal.

    Use when: PUT /goals/{id}

    All fields are optional for partial updates.
    """

    title: Optional[str] = Field(
        default=None, min_length=1, max_length=200, description="Updated goal title"
    )

    description: Optional[str] = Field(
        default=None, max_length=1000, description="Updated goal description"
    )

    completed: Optional[bool] = Field(
        default=None, description="Mark goal as completed or not"
    )


# ============================================
# Response Schema (Output from API)
# ============================================


class Goal(GoalBase):
    """
    Complete goal schema returned by the API.

    Use when: API returns goal data (GET, POST, PUT)
    """

    id: int = Field(default=..., description="Unique identifier for the goal")
    user_id: int = Field(default=..., description="ID of the user who owns this goal")
    completed: bool = Field(default=..., description="Whether the goal is completed")

    created_at: datetime = Field(default=..., description="When the goal was created")
    updated_at: Optional[datetime] = Field(
        default=None, description="When the goal was last updated"
    )

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": 1,
                "user_id": 1,
                "title": "Solve 10 LeetCode problems",
                "description": "Focus on arrays and strings",
                "completed": False,
                "created_at": "2025-11-13T10:00:00Z",
                "updated_at": "2025-11-13T10:00:00Z",
            }
        },
    )


# ============================================
# List Response (Multiple Goals)
# ============================================


class GoalList(BaseModel):
    """
    Schema for returning multiple goals.

    Used when: GET /goals (returns all goals)
    """

    goals: List[Goal] = Field(..., description="List of goals")
    total: int = Field(..., description="Total number of goals")
