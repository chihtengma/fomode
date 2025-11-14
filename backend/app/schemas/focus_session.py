"""
FocusSession Pydantic Schemas

These schemas handle validation and serialization for focus mode tracking.

Key features:
    - Start/end session tracking
    - Active session detection
    - Duration calculations
    - Interruption tracking
"""

from datetime import datetime
from typing import Optional, Sequence

from pydantic import BaseModel, ConfigDict, Field

# ============================================
# Base Schema (Shared Fields)
# ============================================


class FocusSessionBase(BaseModel):
    """
    Base schema with common fields.

    Only includes fields taht can be explicitly set.
    Auto-generated fields (id, timestamps) are in response schema.
    """

    # Interrupted flag
    interrupted: bool = Field(
        default=False,
        description="Whether user tried to open blocked apps during focus",
    )


# ============================================
# Create Schema (Input for POST /focus/start)
# ============================================


class FocusSessionCreate(BaseModel):
    """
    Schemas for starting a new focus session

    Used when: POST /focus/start

    When user taps "Start Focus Mode", we create a session with:
        - start_time: Set automatically by database
        - end_time: NULL (session is active)
        - duration: 0 (will be calculated later)
        - interrupted: False (default)

    This schema is almost empty because everything is auto-generated.
    We might not even need a request body.

    Example request (empty body or minimal):
        {}

    Or with optional message:
        {
            "interrupted": false
        }
    """

    # Optional: Allow manually setting interrupted
    # Normally this starts as Flase
    interrupted: Optional[bool] = Field(
        default=False, description="initial interrupted state (usually false)"
    )


# ============================================
# End Session Schema (Input for POST /focus/end)
# ============================================


class FocusSessionEnd(BaseModel):
    """
    Session for ending an active focus session.

    Used when: POST /focus/end/{session_id}

    When use taps "End Focus Mode", we need:
        - Session ID (from URL parameter)
        - Optional: whether it was interrupted

    The endpoint will:
        1. Set end_time to now
        2. Calculate duration
        3. Update interrupted flag if provided

    Example request:
        {
            "interrupted": false
        }
    """

    interrupted: Optional[bool] = Field(
        None, description="Whether session was interrupted (optional update)"
    )


# ============================================
# Update Schema (Input for PATCH /focus/{id})
# ============================================


class FocusSessionUpdate(BaseModel):
    """
    Schema for updating a focus session.

    Used when: PATCH /focus/{id}

    Allowing updating:
        - interrupted flag (mark that user tried to break focus)
        - end_time (if manually ending)

    All fields optional for partial updates.

    Example: User tried to open TikTok during focus
        {
            "interrupted": true
        }
    """

    interrupted: Optional[bool] = Field(None, description="Updated interrupted status")
    end_time: Optional[datetime] = Field(
        None, description="Manually set end time (usually auto-set)"
    )


# ============================================
# Response Schema (Output from API)
# ===========================================


class FocusSession(FocusSessionBase):
    """
    Complete focus session schema returned by the API.

    Used when: API returns focus session data

    Includes everything:
        - Database fields (id, user_id, times)
        - Computed properties (is_active, duration_minutes)

    Example response:
        {
            "id": 1,
            "user_id": 1,
            "start_time": "2025-11-13T14:00:00Z",
            "end_time" null,
            "duration": 1800,
            "duration_minutes": 30.0,
            "duration_hours": 0.5,
            "interrupted": false,
            "is_active": true,
            "created_at": "2025-11-13T14:00:00Z"
        }
    """

    id: int = Field(default=..., description="Unique identifier")
    user_id: int = Field(default=..., description="ID of user who owns this session")
    start_time: datetime = Field(default=..., description="When focus mode was enabled")
    end_time: Optional[datetime] = Field(
        None, description="When focus mode was disabled (null if active"
    )
    duration: int = Field(
        default=..., ge=0, description="Total focus duration in seconds"
    )
    created_at: datetime = Field(
        default=..., description="When this record was created"
    )

    # Computed properties
    @property
    def is_active(self) -> bool:
        """
        Check if session is currently active.
        """
        return self.end_time is None

    @property
    def duration_minutes(self) -> float:
        """Get duration in minutes"""
        return self.duration / 60.0 if self.duration else 0.0

    @property
    def duration_hours(self) -> float:
        """Get duration in hours"""
        return self.duration / 3600.0 if self.duration else 0.0

    # Pydantic v2 configuration
    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "examples": [
                {
                    "description": "Active focus session",
                    "value": {
                        "id": 1,
                        "user_id": 1,
                        "start_time": "2025-11-13T14:00:00Z",
                        "end_time": None,
                        "duration": 1800,
                        "interrupted": False,
                        "is_active": True,
                        "created_at": "2025-11-13T14:00:00Z",
                    },
                },
                {
                    "description": "Completed focus session",
                    "value": {
                        "id": 2,
                        "user_id": 1,
                        "start_time": "2025-11-13T10:00:00Z",
                        "end_time": "2025-11-13T11:30:00Z",
                        "duration": 5400,
                        "interrupted": True,
                        "is_active": False,
                        "created_at": "2025-11-13T10:00:00Z",
                    },
                },
            ]
        },
    )


# ============================================
# Focus Statistics Schema
# ============================================


class FocusStats(BaseModel):
    """
    Schemas for focus session statistics.

    Used when: GET /focus/stats

    Aggregates data to show user thier focus metrics:
        - Total focus time today
        - Number of sessions
        - Average session length
        - Longest session
        - Clean vs interrupted sessions

    Example response:
        {
            "date": "2025-11-13",
            "total_sessions": 5,
            "total_duration_seconds": 7200,
            "total_duration_hours": 2.0,
            "average_session_minutes": 24.0,
            "longest_session_minutes": 45.0,
            "clean_sessions": 3,
            "interrupted_sessions": 2,
            "active_session": {...}
        }
    """

    date: str = Field(
        default=...,
        description="Date for these statistics (YYYY-MM-DD)",
        examples=["2025-11-13"],
    )

    total_sessions: int = Field(
        default=0, ge=0, description="Total number of focus sessions"
    )

    total_duration_seconds: int = Field(
        default=0, ge=0, description="Total focus time in seconds"
    )

    total_duration_hours: float = Field(
        default=0.0, ge=0.0, description="Total focus time in hours"
    )

    average_session_minutes: float = Field(
        default=0.0, ge=0.0, description="Average focus session length in minutes"
    )

    longest_session_minutes: float = Field(
        default=0.0, ge=0.0, description="Longest focus session in minutes"
    )

    clean_sessions: int = Field(
        default=0, ge=0, description="Number of uninterrupted sessions"
    )

    interrupted_sessions: int = Field(
        default=0, ge=0, description="Number of interrupted sessions"
    )

    active_session: Optional[FocusSession] = Field(
        None, description="Currently active focus session (if any)"
    )

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "date": "2025-11-13",
                "total_sessions": 5,
                "total_duration_seconds": 7200,
                "total_duration_hours": 2.0,
                "average_session_minutes": 24.0,
                "longest_session_minutes": 45.0,
                "clean_sessions": 3,
                "interrupted_sessions": 2,
                "active_session": None,
            }
        }
    )


# ============================================
# Session List Response
# ============================================


class FocusSessionList(BaseModel):
    """
    Schema for returning multiple focus sessions.
    """

    model_config = ConfigDict(from_attributes=True)
    sessions: Sequence[FocusSession] = Field(..., description="List of focus sessions")

    total: int = Field(default=..., ge=0, description="Total number of sessions")

    active_session: Optional[FocusSession] = None
