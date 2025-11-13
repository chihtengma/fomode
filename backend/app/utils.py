from datetime import datetime
from typing import Any, Optional


def to_iso(value: Any) -> Optional[str]:
    """
    Convert a value to ISO 8601 string format for JSON serialization.

    Args:
        value: The value to convert. Can be a datetime object or any other type.

    Returns:
        Optional[str]:
            - If value is a datetime: Returns ISO 8601 formatted string (e.g., "2025-11-13T14:30:00")
            - If value is not None: Returns string representation of the value
            - If value is None: Returns None
    """
    if isinstance(value, datetime):
        return value.isoformat()

    return str(value) if value is not None else None
