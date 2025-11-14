"""
Main FastAPI Application Entry Point.

This is the core of API. It creates the FastAPI app instance and configures all the middleware, routes,
and startup/shutdown events.
"""

import os
from contextlib import asynccontextmanager
from typing import Any, AsyncIterator, List

from dotenv import load_dotenv
from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.engine.reflection import Inspector
from sqlalchemy.orm import Session

from app.database import get_db

load_dotenv()  # Load environment variables from .env file


# Lifespan Contextd Mapper
# This handles startup and shutdown events for the application
@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    # STARTUP: Code here runs when the application starts
    print("=" * 60)
    print("🚀 Starting Anti-Procrastination API...")
    print("=" * 60)
    print("📝 API Docs: http://localhost:8000/docs")
    print(f"🔄 Environment: {os.getenv('ENVIRONMENT', 'development')}")
    print("=" * 60)

    # Initialize database tables
    print("\n🗄️  Initializing database...")
    from app.database import init_db

    try:
        init_db()
        print("✅ Database initialization complete!\n")
    except Exception as err:
        print(f"❌ Database initialization failed: {err}\n")
        raise

    print("=" * 60)
    print("✅ Application startup complete!")
    print("=" * 60)

    # The yield separates startup from shutdown
    yield

    # SHUTDOWN: Code here runs when the application shuts down
    print("\n" + "=" * 60)
    print("👋 Shutting down Anti-Procrastination API...")
    print("=" * 60)
    print("✅ Cleanup completed")
    print("=" * 60)

    # TODO: Close any open connections, save state, etc.
    # Example:
    # await database.disconnect()
    # await redis.close())


# Create FastAPI app instance
# The 'app' object is what uvicorn will look for to run the server
app: FastAPI = FastAPI(
    # Title and description for API documentation
    title=os.getenv("API_TITLE", "Fomode API"),
    # Version of the API
    version=os.getenv("API_VERSION", "0.1.0"),
    # Description appears in API Docs
    description=os.getenv("API_DESCRIPTION", "API for Fomode application"),
    # Auto-generated documentation URLs
    # - /docs provides Swagger UI (interactive API testing)
    # - /redoc provides ReDoc UI (alternative documentation style)
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS (Cross-Origin Resource Sharing) Middleware
# This allows the API to be accessed from different origins (e.g., frontend apps)
app.add_middleware(
    middleware_class=CORSMiddleware,
    # List of origins (domains) allowed to make requests
    # In production, this should be set to the actual frontend URL(s)
    # ["http://localhost:3000", "https://your-frontend-domain.com"]
    allow_origins=os.getenv("ALLOWED_ORIGINS", "*").split(","),
    # Allow credentials (cookies, authorization headers)
    allow_credentials=True,
    # Allow all HTTP methods (GET, POST, PUT, DELETE, etc.)
    allow_methods=["*"],
    # Allow all headers (Content-Type, Authorization, etc.)
    allow_headers=["*"],
)

# ============================================
# Include Routers
# ============================================

# Import routers
from app.routers import goals, tracking  # noqa: E402

# Include routers with prefixes
app.include_router(goals.router)
app.include_router(tracking.router)


# Root Endpoint (Health Check)
# This simple endpoint lets us check if the API is running
# Useful for monitoring and debugging
@app.get(path="/", tags=["Health Check"])
async def root() -> dict:
    return {
        "message": "Fomode API is running! 🎯",
        "status": "healthy",
        "version": os.getenv("API_VERSION", "0.1.0"),
        "docs": "/docs",
        "endpoints": {
            "goals": "/goals",
            "tracking": "/tracking",
            "focus": "/focus (coming soon)",
        },
    }


# API Information Endpoint
# provides metadata about the API
@app.get(path="/info", tags=["API Info"])
async def api_info() -> dict:
    return {
        "title": os.getenv("API_TITLE", "Fomode API"),
        "version": os.getenv("API_VERSION", "0.1.0"),
        "environment": os.getenv("ENVIRONMENT", "development"),
        "description": os.getenv("API_DESCRIPTION", "API for Fomode application"),
        "available_endpoints": {
            "goals": "/goals",
            "tracking": "/tracking",
            "focus": "/focus (coming soon)",
        },
    }


@app.get(path="/init-db")
async def initialize_database() -> dict[str, str]:
    """
    Manually initialize database tables.

    This creates all tables defined in models.
    Safe to call multiple times (won't recreate existing tables).
    """
    try:
        from app.database import init_db

        init_db()
        return {
            "status": "success",
            "message": "Database tables created successfully! ✅",
        }
    except Exception as e:
        import traceback

        return {
            "status": "error",
            "message": f"Failed to create tables: {str(e)}",
            "traceback": traceback.format_exc(),
        }


@app.get(path="/db-test")
async def test_database(
    db: Session = Depends(dependency=get_db),
) -> dict[str, str] | dict[str, Any]:
    """
    Test database connection and models.

    This endpoint:
        1. Tests database connectivity
        2. Shows table input
        3. Creates a test goal and retrieves it

    Returns:
        dict: Test results
    """
    from sqlalchemy import inspect

    from app.database import engine
    from app.models import FocusSession, Goal, UsageLog

    try:
        inspector: Inspector = inspect(engine)
        tables: List[str] = inspector.get_table_names()

        # Count existing records
        goal_count: int = db.query(Goal).count()
        usage_count: int = db.query(UsageLog).count()
        focus_count: int = db.query(FocusSession).count()

        # Try to create a test goal
        test_goal = Goal(
            user_id=1,
            title="Test Goal - Database Connection",
            description="This is a test goal to verify database is working",
        )
        db.add(test_goal)
        db.commit()
        db.refresh(test_goal)

        return {
            "status": "success",
            "message": "Database connection successful! ✅",
            "tables": tables,
            "record_counts": {
                "goals": goal_count,
                "usage_logs": usage_count,
                "focus_sessions": focus_count,
            },
            "test_goal_created": {
                "id": test_goal.id,
                "title": test_goal.title,
                "completed": test_goal.completed,
                "created_at": test_goal.created_at,
            },
        }
    except Exception as err:
        return {"status": "error", "message": f"Database test failed: {str(err)}"}
