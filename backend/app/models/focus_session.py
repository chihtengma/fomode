"""
FocusSession Model - SQLAlchemy Database Model

Tracks focus mode sessions — when a user activates "focus mode"
to block distracting apps.
"""

from datetime import datetime, timedelta
from typing import Optional

from sqlalchemy import Boolean, DateTime, Integer
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.database import Base
from app.utils import to_iso


class FocusSession(Base):
    __tablename__ = "focus_sessions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(Integer, index=True, nullable=False, default=1)

    # When focus mode started
    start_time: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        index=True,
    )

    # When focus mode ended (NULL if still active)
    end_time: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    # Duration in seconds
    duration: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    # Whether the user tried to open blocked apps
    interrupted: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)

    # Record creation time
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), nullable=False
    )

    def __repr__(self) -> str:
        """String representation."""
        return (
            f"<FocusSession(duration={self.duration}, "
            f"interrupted={self.interrupted}, active={self.is_active})>"
        )

    def to_dict(self) -> dict[str, object]:
        """
        Convert FocusSession object to a dictionary
        with ISO-formatted timestamps.
        """
        return {
            "id": self.id,
            "user_id": self.user_id,
            "start_time": to_iso(value=self.start_time),
            "end_time": to_iso(value=self.end_time),
            "duration": self.duration,
            "duration_minutes": self.duration_minutes,
            "interrupted": self.interrupted,
            "is_active": self.is_active,
            "created_at": to_iso(self.created_at),
        }

    @property
    def is_active(self) -> bool:
        """Check if the focus session is currently active."""
        return self.end_time is None

    @property
    def duration_minutes(self) -> float:
        """Helper to get duration in minutes."""
        return self.duration / 60.0 if self.duration else 0.0

    @property
    def duration_hours(self) -> float:
        """Helper to get duration in hours (e.g., 1.5 for 90 minutes)."""
        return self.duration / 3600.0 if self.duration else 0.0

    def calculate_duration(self) -> int:
        """
        Calculate duration (in seconds) based on start_time and end_time.

        Called when ending a focus session or updating live timers.
        """
        if not self.start_time:
            return 0

        delta: timedelta
        if self.end_time:
            delta = self.end_time - self.start_time
        else:
            now: datetime = datetime.now(self.start_time.tzinfo)
            delta = now - self.start_time

        self.duration = int(delta.total_seconds())
        return self.duration
