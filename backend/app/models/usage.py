"""
Usage Model - SQLAlchemy Database Model

Tracks every time a user opens a time-wasting app (TikTok, Instagram, etc.)
and records what action was taken (intercepted, allowed, blocked).
"""

from datetime import datetime

from sqlalchemy import Boolean, DateTime, Integer, String
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.database import Base
from app.utils import to_iso


class UsageLog(Base):
    __tablename__ = "usage_logs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(Integer, index=True, nullable=False, default=1)

    # Human readable name, "TikTok", "Instagram", "Youtube"
    app_name: Mapped[str] = mapped_column(String(100), nullable=False)

    # Package Name (Technical identifier)
    # Android: "com.zhiliaoapp.musically" (TikTok)
    # iOS: Bundle identifier
    # This is what we actually detect in the code
    package_name: Mapped[str] = mapped_column(String(255), nullable=False, index=True)

    # Duration (in seconds), user spent in this app
    duration: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    # Was Intercepted?
    # True: Showed the interception dialog
    # False: They used the app without intervention (shouldn't happen often)
    intercepted: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)

    # Action Taken
    # Possible values:
    #   - "allowed_5min": User choose to take a 5-minute break
    #   - "cancelled": User chose "accidentally opened" and closed
    #   - "blocked": Focus mode was on, app was blocked
    #   - "override": User forced past the block (future feature)
    action_taken: Mapped[str] = mapped_column(String(50), nullable=False)

    # Timestamp
    # When this usage event occurred
    # For daily/weekly statistics
    timestamp: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        index=True,  # Index because we query by time range often
    )

    def __repr__(self) -> str:
        """String representation."""
        return (
            f"<UsageLog(id={self.id}, app='{self.app_name}', "
            f"duration={self.duration}s, action='{self.action_taken}')>"
        )

    def to_dict(self) -> dict[str, object]:
        """
        Safely convert UsageLog object to dictionary
        with ISO-formatted timestamps.
        """
        return {
            "id": self.id,
            "user_id": self.user_id,
            "app_name": self.app_name,
            "package_name": self.package_name,
            "duration": self.duration,
            "intercepted": self.intercepted,
            "action_taken": self.action_taken,
            "timestamp": to_iso(value=self.timestamp),
        }

    @property
    def duration_minutes(self) -> float:
        """
        Helper to get duration in minutes.
        """
        return self.duration / 60.0 if self.duration else 0.0
