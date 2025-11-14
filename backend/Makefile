# Makefile for Fomode Backend
# This simplifies common Docker and development commands

.PHONY: help up up-bg down build restart logs shell db-shell clean test init

# Default target - show help
help:
	@echo "Fomode Backend - Available Commands:"
	@echo ""
	@echo "  make up          - Start containers and show logs (Ctrl+C to detach)"
	@echo "  make up-bg       - Start containers in background, return to terminal"
	@echo "  make down        - Stop containers"
	@echo "  make build       - Build/rebuild containers"
	@echo "  make restart     - Restart containers"
	@echo "  make logs        - View container logs"
	@echo "  make logs-f      - Follow container logs (real-time)"
	@echo "  make shell       - Open shell in API container"
	@echo "  make db-shell    - Open PostgreSQL shell"
	@echo "  make clean       - Stop containers and remove volumes (⚠️  deletes data)"
	@echo "  make test        - Run API health check"
	@echo "  make init        - Initialize database tables"
	@echo "  make status      - Show container status"
	@echo ""

# Start containers with logs (Ctrl+C to stop watching, containers keep running)
up:
	docker-compose up

# Start containers in background, show startup logs, then return to terminal
up-bg:
	@echo "🚀 Starting containers..."
	@docker-compose up -d
	@echo ""
	@echo "⏳ Waiting for services to start..."
	@sleep 2
	@echo ""
	@echo "📋 Startup logs:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@docker-compose logs --tail=50
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "✅ Containers running in background!"
	@echo "📝 API: http://localhost:8000"
	@echo "📝 Docs: http://localhost:8000/docs"
	@echo "🗄️  Database: localhost:5432"
	@echo ""
	@echo "💡 Tips:"
	@echo "   - View live logs: make logs-f"
	@echo "   - Stop containers: make down"
	@echo "   - Restart API: make restart-api"
	@echo ""

# Stop containers
down:
	@echo "🛑 Stopping containers..."
	docker-compose down
	@echo "✅ Containers stopped!"

# Build or rebuild containers
build:
	@echo "🔨 Building containers..."
	docker-compose build
	@echo "✅ Build complete!"

# Rebuild and start in background
rebuild:
	@echo "🔨 Rebuilding and starting containers..."
	@docker-compose up --build -d
	@sleep 2
	@docker-compose logs --tail=30
	@echo ""
	@echo "✅ Containers rebuilt and started!"

# Restart containers
restart:
	@echo "🔄 Restarting containers..."
	docker-compose restart
	@echo "✅ Containers restarted!"

# Restart only API (faster for code changes)
restart-api:
	@echo "🔄 Restarting API container..."
	docker-compose restart api
	@echo "✅ API restarted!"

# View logs (last 100 lines)
logs:
	docker-compose logs --tail=100

# Follow logs in real-time (Ctrl+C to exit)
logs-f:
	docker-compose logs -f

# View only API logs
logs-api:
	docker-compose logs -f api

# View only DB logs
logs-db:
	docker-compose logs -f db

# Open shell in API container
shell:
	@echo "🐚 Opening shell in API container..."
	docker exec -it fomode_api /bin/bash

# Open PostgreSQL shell
db-shell:
	@echo "🗄️  Opening PostgreSQL shell..."
	@echo "Commands: \\dt (list tables), \\d table_name (describe table), \\q (quit)"
	docker exec -it fomode_db psql -U fomode_user -d fomode_db

# Clean up everything (⚠️  removes volumes and data)
clean:
	@echo "⚠️  WARNING: This will delete all data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "🧹 Cleaning up..."; \
		docker-compose down -v; \
		echo "✅ Cleanup complete!"; \
	else \
		echo "❌ Cancelled."; \
	fi

# Show container status
status:
	@echo "📊 Container Status:"
	@docker-compose ps

# Health check - test if API is running
test:
	@echo "🧪 Testing API health..."
	@curl -s http://localhost:8000/ | python -m json.tool || echo "❌ API not responding"

# Initialize database tables
init:
	@echo "🗄️  Initializing database tables..."
	@curl -s http://localhost:8000/init-db | python -m json.tool
	@echo ""

# Run database test
db-test:
	@echo "🧪 Testing database connection..."
	@curl -s http://localhost:8000/db-test | python -m json.tool
	@echo ""

# Show database info
db-info:
	@echo "🗄️  Database Information:"
	@echo "Host: localhost"
	@echo "Port: 5432"
	@echo "Database: fomode_db"
	@echo "User: fomode_user"
	@echo "Password: dev_password_123"
	@echo ""
	@echo "Connection string:"
	@echo "postgresql://fomode_user:dev_password_123@localhost:5432/fomode_db"

# Stop and remove only API container (for quick rebuild)
reset-api:
	@echo "🔄 Resetting API container..."
	docker-compose stop api
	docker-compose rm -f api
	docker-compose up -d api
	@echo "✅ API container reset!"

# Install/update Python dependencies
deps:
	@echo "📦 Installing Python dependencies..."
	docker-compose exec api pip install -r requirements.txt
	@echo "✅ Dependencies installed!"
