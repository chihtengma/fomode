"""
Database Configuration Module

This file handles all database connection setup for FastAPI application.
It uses SQLAlchemy as the ORM (Object-Relational Mapping) tool, which lets us work
with databases tables as if they were Python classes.
"""

import os

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.sql.base import Generator

load_dotenv()  # Reads .env file and loads variables

# Database URL
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://fomode_user:dev_password_123@localhost:5432/fomode_db",  # Fallback URL if .env it not set
)

# Create SQLAlchemy engine
# The engine manages connections to the database
engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,  # Health check before using a connection
    echo=True,  # Log SQL queries for debugging (Set to False in production)
)

# Create a SessionLocal class
# Sessions are how we interact with the database
SessionLocal = sessionmaker(
    autocommit=False,  # Manually control when to save changes (safer)
    autoflush=False,  # Manually control when to send queries to the database
    bind=engine,  # Connect this session to our engine
)

# Create Base class for our models
# All our database models will inherit from this
# This base class tracks all model definitions and can create tables
Base = declarative_base()


# Dependency function for FastAPI routes
# This function provides a database session to each API endpoint
# FastAPI's dependency injection system calls this automatically
def get_db() -> Generator[Session, None, None]:
    db: Session = SessionLocal()  # Create a new database session

    try:
        # Yield the session to the route function
        # The route can now use 'db' to query/modify the database
        yield db
    except Exception as err:
        # Handle any exceptions that occur during database operations
        print(f"Database error: {err}")
        raise err  # Re-raise the exception to be handled by FastAPI
    finally:
        # This always runs after the route completes
        # Close the session to free up database connections
        db.close()


# Helper function to initialize database tables
def init_db() -> None:
    """
    Creates all database tables.

    This function calls when the application starts.
    It creates tables for all models that inherit from Base.

    NOTE: In production, we'll use Alembic for migrations instead, but this is useful for development.
    """

    # Import all models here to ensure they are registered with Base

    Base.metadata.create_all(bind=engine)
    print("✅ Database tables created successfully!")
