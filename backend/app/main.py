"""
Main FastAPI Application Entry Point.

This is the core of API. It creates the FastAPI app instance and configures all the middleware, routes,
and startup/shutdown events.
"""

import os
from contextlib import asynccontextmanager
from typing import AsyncIterator

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

load_dotenv()  # Load environment variables from .env file


# Lifespan Contextd Mapper
# This handles startup and shutdown events for the application
@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    # STARTUP: Code here runs when the application starts
    print("🚀 Starting Fomode API...")
    print("📝 API Docs available at: http://localhost:8000/docs")
    print("🔧 Environment:", os.getenv("ENVIRONMENT", "development"))

    # TODO: Initialize database connections, load models, etc.

    yield

    # SHUTDOWN: Code here runs when the application shuts down
    print("👋 Shutting down Anti-Procrastination API...")
    print("✅ Cleanup completed")

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
    CORSMiddleware,
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
    }


# TODO: Add routers here as we build them
# Example:
# from app.routers import goals, tracking
# app.include_router(goals.router, prefix="/goals", tags=["goals"])
# app.include_router(tracking.router, prefix="/tracking", tags=["tracking"])
