"""
UsageLog Pydantic Schemas

These schemas handle validation and serialization for app usage tracking.

Key difference from Goal schemas:
    - More fields (app_name, package_name, duration, etc.)
    - action_taken has restricted values (enum-like validation)
    - Different use cases (logging events vs managing goals)
"""

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, field_validator

# ============================================
# Base Schema (Shared Fields)
# ============================================


class UsageLogBase(BaseModel):
    """
    Base schema with common fields for usage logging.

    These are the fields that the mobile app will send when logging an app usage event
    """

    # App name (human-readable)
    app_name: str = Field(
        default=...,
        min_length=1,
        max_length=100,
        description="User-friendly app name",
        examples=["TikTok", "Instagram", "Youtube"],
    )

    # Package name (technical identifier)
    package_name: str = Field(
        default=...,
        min_length=1,
        max_length=255,
        description="App package/bundle identifier",
        examples=[
            "com.zhiliaoapp.musically",  # TikTok Android
            "com.instagram",  # Instagram
            "com.burbn.instagram",  # Instagram iOS
        ],
    )

    # Duration in seconds
    duration: int = Field(
        default=0,
        ge=0,  # Greater than or equal to 0 (no negative durations)
        description="Duration the app was used (in seconds)",
        examples=[0, 300, 600],  # 0s, 5min, 10min
    )

    # was intercepted?
    intercepted: bool = Field(
        default=False, description="Whether the interception dialog was shown"
    )

    # Action taken
    # We'll validate this specific values
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
    """
    Schema for creating a new usage log entry.

    Use when: POST /tracking/log

    The mobile app sends this when:
        1. User opens a time-wasting app
        2. User takes an action (allow, cancel, etc.)
        3. App is closed (to update duration)

    Example request from frontend:
        {
            "app_name": "TikTok",
            "pacakge_name": "com.zhiliaoapp.musically",
            "duration": 300,
            "intercepted": true,
            "action_taken": "allowed_5min"
        }
    """

    # Custom validator for action_taken
    # This ensures only valid actions are accepted
    @field_validator("action_taken")
    @classmethod
    def validate_action(cls, val: str) -> str:
        """
        Validate the action_taken is one fo the allowed value.

        Allowed actions:
            - allowed_5min: User chose to take a 5-minute break
            - cancelled: User chose "accidentally opened"
            - blocked: Focus mode blocked the app
            - override: User forced past the block (future feature)

        Args:
            val: The action_taken value to validate

        Returns:
            str: The validated action value

        Raises:
            ValueError: If action is not in allowed list
        """
        allowed_actions = [
            "allowed_5mi",
            "cancelled",
            "blocked",
            "override",
        ]

        if val not in allowed_actions:
            raise ValueError(
                f"action_taken must be one of: {','.join(allowed_actions)}. Got: {val}"
            )

        return val


# ============================================
# Response Schema (Output from API)
# ============================================


class UsageLog(UsageLogBase):
    """
    Complete usage log schema returned by the API.

    Used when: API returns usage log data

    Includes all fields from UsageLogBase plus:
        - id (primary key)
        - user_id (who this belongs to)
        - timestamp (when it happened)

    Example response:
        {
            "id": 123,
            "user_id": 1,
            "app_name": "TikTok",
            "package_name": "com.zhiliaoapp.musically",
            "duration": 300,
            "duration_minutes": 5.0,
            "intercepted": true,
            "action_taken": "allowed_5min",
            "timestamp": "2025-11-13T14:30:00Z"
        }
    """

    # Primary key
    id: int = Field(default=..., description="Unique identifier for this usage log")

    # User ID
    user_id: int = Field(default=..., description="ID of the user who owns this log")

    # Timestamp
    timestamp: datetime = Field(
        default=..., description="When this usage event occurred"
    )

    # Computed field: duration in minutes
    # # This is not soted in DB, calculated on-the-fly
    @property
    def duration_minutes(self) -> float:
        """
        Get duration in minutes (computed property)

        This appears in the JSON response but isn't a db field.

        Returns:
            float: Duration in minutes
        """
        return self.duration / 60.0 if self.duration else 0.0

    # Pydantic v2 configuration
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
    """
    Schema for daily usage statistics.

    Used when: GET /tracking/stats

    Aggregates usage data to show user their daily stats:
        - Total time wasted on apps
        - Number of interceptions
        - Most used apps
        - etc.

    Example response:
        {
            "date": "2025-11-13",
            "total_duration_seconds": 1800,
            "total_duration_minutes": 30.0,
            "total_logs": 12,
            "interception_count": 8,
            "most_used_apps": [
                {"app_name": "TikTok", "duration": 600},
                {"app_name": "Instagram", "duration": 480}
            ]
        }
    """

    # Date for these stats
    date: str = Field(
        default=...,
        description="Date for these statistics (YYYY-MM-DD foramt)",
        examples=["2025-11-13"],
    )

    # Total time spent in seconds
    total_duration_seconds: int = Field(
        default=0, ge=0, description="Total time spent on time-wasting apps (seconds)"
    )

    # Total time in minutes (more readable)
    total_duration_minutes: float = Field(
        default=0.0,
        ge=0.0,
        description="Total time spent on time-wasting apps (mintues)",
    )

    # Number of usage logs
    total_logs: int = Field(
        default=0, ge=0, description="Total number of app usage events today"
    )

    # Number of interceptions
    interception_count: int = Field(
        default=0, ge=0, description="Number of times user was intercepted"
    )

    # Most used apps
    most_used_apps: list[dict] = Field(
        default_factory=list,
        description="List of most used apps with duration",
        examples=[
            [
                {"app_name": "TikTok", "duration": 600},
                {"app_name": "Instagram", "duration": 480},
            ]
        ],
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
                    {"app_name": "TikTok", "duration": 600},
                    {"app_name": "Instagram", "duration": 480},
                    {"app_name": "YouTube", "duration": 420},
                ],
            }
        }
    )


# ============================================
# App Usage Summary (Per App)
# ============================================


class AppUsageSummary(BaseModel):
    """
    Summary of usaged for a single app.

    Used in: most_used_apps field in UsageStats

    Show how much time was spent on each app.
    """

    app_name: str = Field(default=..., description="Name of the app")
    package_name: str = Field(default=..., description="Package identifier")
    total_duration: int = Field(default=..., description="Total duration (seconds)")
    usage_count: int = Field(default=..., description="Number of times app was openend")
    interceptioj_count: int = Field(
        default=..., description="Number of times intercepted"
    )
