# use official Python runtime as base image
# python:3.12-slim is a lightweight version of Python 3.12
# "slim" means it has fewer pre-installed packages, making it smaller and faster to download
FROM python:3.12-slim

# Set working directroy in the container
# All subsequent commands will run from this directory
WORKDIR /app

# Install system dependencies
# These are required for psycopg2 (PostgreSQL driver) to work
# - gcc, g++ = compilers needed to build python packages
# - libpq-dev = PostgreSQL development libraries
# We use --no-install-recommends to keep image size small
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libpq-dev \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements file first
# Docker caches layers, so if requirements.txt doesn't change
# this layer will be reused (save time during rebuilds)
COPY requirements.txt .

# Install Python dependencies
# --no-cache-dir prevents pip from storing cache (save space)
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
# This copies everything from backend/ directory into the container
COPY . .

# Expose port 8000
# This tells Docker that our app listens on port 8000
# (Doesn't really publish the port, docker-compose will handle that)
EXPOSE 8000

# Command to run the application
# uvicorn runs our FastAPI app
# - app.main:app means: in the 'app' folder, in 'main.py', run the 'app' object
# - --host 0.0.0.0 makes it accessible from outside the container
# - --port 8000 is the port inside the container
# - --reload enables auto-restart when code changes (development only)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
