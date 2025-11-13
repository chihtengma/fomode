"""
Goal Model - SQLAlchemy Database Model

Goal model represents user's daily objectives.
"""

from datetime import datetime
from typing import Optional

from sqlalchemy import Boolean, DateTime, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from app.database import Base
from app.utils import to_iso


class Goal(Base):
    __tablename__ = "goals"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(Integer, index=True, nullable=False, default=1)
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    completed: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
    updated_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=True,
    )

    def __repr__(self) -> str:
        """
        String representation of the Goal object.

        Example:
        <Goal(id=1, title="Solve 10 LeetCode problems", completed=Fasle)>
        """
        return f"<Goal(id={self.id}, title='{self.title}', completed={self.completed})>"

    def to_dict(self) -> dict[str, object]:
        """
        Safely convert Goal object to dictionary with ISO-formatted timestamps.
        """

        return {
            "id": self.id,
            "user_id": self.user_id,
            "title": self.title,
            "description": self.description,
            "completed": self.completed,
            "created_at": to_iso(value=self.created_at),
            "updated_at": to_iso(value=self.updated_at),
        }
