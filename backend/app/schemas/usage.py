"""
UsageLog Pydantic Schemas

These schemas handle validation and serialization for app usage tracking.
"""

from datetime import datetime
from typing import List

from pydantic import BaseModel, ConfigDict, Field, field_validator

# ============================================
# Base Schema (Shared Fields)
# ============================================


class UsageLogBase(BaseModel):
    """Base schema with common fields for usage logging."""

    app_name: str = Field(
        default=...,
        min_length=1,
        max_length=100,
        description="User-friendly app name",
        examples=["TikTok", "Instagram", "YouTube"],
    )

    package_name: str = Field(
        default=...,
        min_length=1,
        max_length=255,
        description="App package/bundle identifier",
        examples=[
            "com.zhiliaoapp.musically",  # TikTok Android
            "com.instagram",  # Instagram
            "com.burbn.instagram",  # Instagram iOS (historic)
        ],
    )

    duration: int = Field(
        default=0,
        ge=0,
        description="Duration the app was used (in seconds)",
        examples=[0, 300, 600],
    )

    intercepted: bool = Field(
        default=False, description="Whether the interception dialog was shown"
    )

    action_taken: str = Field(
        default=...,
        min_length=1,
        max_length=50,
        description="Action taken during interception",
        examples=["allowed_5min", "cancelled", "blocked", "override"],
    )


# ============================================
# Create Schema (Input for POST /tracking/log)
# ============================================


class UsageLogCreate(UsageLogBase):
    """Schema for creating a new usage log entry."""

    @field_validator("action_taken")
    @classmethod
    def validate_action(cls, val: str) -> str:
        """
        Validate the action_taken is one of the allowed values.
        """
        allowed_actions = [
            "allowed_5min",
            "cancelled",
            "blocked",
            "override",
        ]

        if val not in allowed_actions:
            raise ValueError(
                f"action_taken must be one of: {', '.join(allowed_actions)}. Got: {val}"
            )

        return val


# ============================================
# App Usage Summary (Per App) - MUST come before UsageStats
# ============================================


class AppUsageSummary(BaseModel):
    """
    Summary of usage for a single app.
    Used in: most_used_apps field in UsageStats
    """

    app_name: str = Field(default=..., description="Name of the app")
    package_name: str = Field(default=..., description="Package identifier")
    total_duration: int = Field(default=0, description="Total duration (seconds)")
    usage_count: int = Field(default=0, description="Number of times app was opened")
    interception_count: int = Field(
        default=0, description="Number of times intercepted"
    )


# ============================================
# Response Schema (Output from API)
# ============================================


class UsageLog(UsageLogBase):
    """Complete usage log schema returned by the API."""

    id: int = Field(default=..., description="Unique identifier for this usage log")
    user_id: int = Field(default=..., description="ID of the user who owns this log")
    timestamp: datetime = Field(
        default=..., description="When this usage event occurred"
    )

    # Computed property (not stored in DB)
    @property
    def duration_minutes(self) -> float:
        return self.duration / 60.0 if self.duration else 0.0

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": 123,
                "user_id": 1,
                "app_name": "TikTok",
                "package_name": "com.zhiliaoapp.musically",
                "duration": 300,
                "intercepted": True,
                "action_taken": "allowed_5min",
                "timestamp": "2025-11-13T14:30:00Z",
            }
        },
    )


# ============================================
# Statistics Schema (For GET /tracking/stats)
# ============================================


class UsageStats(BaseModel):
    """Schema for daily usage statistics."""

    date: str = Field(
        default=...,
        description="Date for these statistics (YYYY-MM-DD format)",
        examples=["2025-11-13"],
    )

    total_duration_seconds: int = Field(
        default=0, ge=0, description="Total time spent on time-wasting apps (seconds)"
    )

    total_duration_minutes: float = Field(
        default=0.0,
        ge=0.0,
        description="Total time spent on time-wasting apps (minutes)",
    )

    total_logs: int = Field(
        default=0, ge=0, description="Total number of app usage events today"
    )

    interception_count: int = Field(
        default=0, ge=0, description="Number of times user was intercepted"
    )

    # Now typed to AppUsageSummary so Pyright is happy
    most_used_apps: List[AppUsageSummary] = Field(
        default_factory=list,
        description="List of apps with aggregated usage summary",
    )

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "date": "2025-11-13",
                "total_duration_seconds": 1800,
                "total_duration_minutes": 30.0,
                "total_logs": 12,
                "interception_count": 8,
                "most_used_apps": [
                    {
                        "app_name": "TikTok",
                        "package_name": "com.zhiliaoapp.musically",
                        "total_duration": 600,
                        "usage_count": 3,
                        "interception_count": 2,
                    },
                    {
                        "app_name": "Instagram",
                        "package_name": "com.instagram",
                        "total_duration": 480,
                        "usage_count": 2,
                        "interception_count": 1,
                    },
                ],
            }
        }
    )
