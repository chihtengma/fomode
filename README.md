# Fomode - Anti-Procrastination App

> A smart focus management app that helps you overcome procrastination through active intervention, not passive tracking.

![Version](https://img.shields.io/badge/version-0.1.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## 📖 Overview

Fomode addresses a common problem: knowing what you should do but being unable to do it due to phone distractions. Unlike traditional to-do list apps, Fomode actively intervenes when you're about to procrastinate, turning unconscious habits into conscious choices.

### The Problem

- You know you should study, code, or work
- But time disappears into TikTok, Instagram, YouTube
- Traditional to-do apps don't help at the moment of temptation

### The Solution

- **Smart Interception**: Catches you when opening time-wasting apps
- **Friction Design**: Makes you consciously choose to take a break
- **Focus Mode**: Transforms your phone into a "learning device"
- **Immediate Feedback**: Rewards progress to counter procrastination inertia

## 🎯 Core Features

### MVP v0.1 (Current)

- ✅ Daily goal setting (1-3 specific goals)
- ✅ App usage monitoring & smart interception
- ✅ Focus mode with app blocking
- ✅ Basic usage statistics

### Planned v0.2+

- 🔜 Gamification system (points, badges, levels)
- 🔜 Social accountability features
- 🔜 AI-powered procrastination pattern analysis
- 🔜 Pomodoro technique integration
- 🔜 Data visualization (weekly/monthly reports)

## 🏗 Architecture

```
fomode/
├── backend/           # FastAPI + PostgreSQL
│   ├── app/
│   │   ├── models/    # Database models
│   │   ├── schemas/   # Pydantic validation
│   │   ├── routers/   # API endpoints
│   │   └── core/      # Config & utilities
│   ├── Dockerfile
│   └── docker-compose.yml
│
└── mobile/            # Flutter (iOS + Android)
    ├── lib/
    │   ├── models/    # Data models
    │   ├── screens/   # UI screens
    │   ├── services/  # Business logic
    │   └── providers/ # State management
    └── pubspec.yaml
```

## 🛠 Tech Stack

### Backend

- **Framework**: FastAPI 0.104.1 (Python 3.11)
- **Database**: PostgreSQL 15
- **ORM**: SQLAlchemy 2.0
- **Validation**: Pydantic 2.5
- **Server**: Uvicorn (ASGI)
- **Container**: Docker + Docker Compose

### Mobile

- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider (or Riverpod)
- **HTTP Client**: Dio
- **Local Storage**: SharedPreferences

### DevOps

- **Version Control**: Git + GitHub
- **Containerization**: Docker
- **Database Migrations**: Alembic (coming soon)

## 🚀 Quick Start

### Prerequisites

- **Backend**: Docker, Docker Compose
- **Mobile**: Flutter SDK, Android Studio / Xcode
- **Tools**: Git, VS Code (recommended)

### Backend Setup

```bash
# 1. Clone repository
git clone <your-repo-url>
cd fomode/backend

# 2. Create environment file
cp .env.example .env
# Edit .env and change passwords

# 3. Start with Docker
docker-compose up --build

# 4. Verify it's running
# Open browser: http://localhost:8000/docs
```

**Backend will be available at:**

- API: http://localhost:8000
- Swagger Docs: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc
- PostgreSQL: localhost:5432

### Mobile Setup

```bash
# 1. Navigate to mobile directory
cd fomode/mobile

# 2. Get dependencies
flutter pub get

# 3. Run on device/emulator
flutter run

# Or build APK
flutter build apk
```

## 📚 Documentation

### Backend API Documentation

Once the backend is running, visit:

- **Interactive docs**: http://localhost:8000/docs
- **Alternative docs**: http://localhost:8000/redoc

### API Endpoints (v0.1)

#### Health Check

```
GET /              # API health check
GET /info          # API information
```

#### Goals (Coming in Step 2)

```
GET    /goals              # List all goals
POST   /goals              # Create new goal
PUT    /goals/{id}         # Update goal
DELETE /goals/{id}         # Delete goal
```

#### Tracking (Coming in Step 2)

```
POST   /tracking/log       # Log app usage event
GET    /tracking/stats     # Get usage statistics
```

#### Focus Sessions (Coming in Step 2)

```
POST   /focus/start        # Start focus session
POST   /focus/end          # End focus session
GET    /focus/history      # Get focus history
```

## 🗂 Project Structure

### Backend Structure

```
backend/
├── app/
│   ├── models/              # SQLAlchemy database models
│   │   ├── goal.py          # Goal model
│   │   ├── usage.py         # Usage log model
│   │   └── focus_session.py # Focus session model
│   ├── schemas/             # Pydantic schemas
│   │   ├── goal.py          # Goal validation
│   │   ├── usage.py         # Usage validation
│   │   └── focus_session.py # Focus session validation
│   ├── routers/             # API route handlers
│   │   ├── goals.py         # Goal endpoints
│   │   ├── tracking.py      # Tracking endpoints
│   │   └── stats.py         # Statistics endpoints
│   ├── core/                # Configuration
│   │   └── config.py        # App config
│   ├── database.py          # Database connection
│   └── main.py              # FastAPI app
├── alembic/                 # Database migrations
├── Dockerfile               # Docker image
├── docker-compose.yml       # Multi-container setup
├── requirements.txt         # Python dependencies
├── .env.example             # Environment template
└── README.md                # Backend documentation
```

### Mobile Structure

```
mobile/
├── lib/
│   ├── main.dart            # App entry point
│   ├── models/              # Data models
│   │   ├── goal.dart
│   │   ├── usage_log.dart
│   │   └── focus_session.dart
│   ├── screens/             # UI screens
│   │   ├── home_screen.dart
│   │   ├── focus_screen.dart
│   │   └── stats_screen.dart
│   ├── widgets/             # Reusable components
│   │   ├── intercept_dialog.dart
│   │   ├── goal_card.dart
│   │   └── timer_widget.dart
│   ├── services/            # Business logic
│   │   ├── api_service.dart
│   │   ├── app_monitor_service.dart
│   │   └── notification_service.dart
│   ├── providers/           # State management
│   │   ├── goal_provider.dart
│   │   ├── focus_provider.dart
│   │   └── stats_provider.dart
│   └── utils/
│       ├── constants.dart
│       └── helpers.dart
├── android/                 # Android platform code
├── ios/                     # iOS platform code
├── pubspec.yaml             # Flutter dependencies
└── README.md                # Mobile documentation
```

## 🔧 Development

### Backend Development

**Start in development mode:**

```bash
cd backend
docker-compose up
```

**View logs:**

```bash
docker-compose logs -f api
```

**Access database:**

```bash
docker exec -it anti_proc_db psql -U anti_proc_user -d anti_procrastination_db
```

**Run migrations (coming soon):**

```bash
alembic upgrade head
```

**Stop containers:**

```bash
docker-compose down
```

**Reset database:**

```bash
docker-compose down -v  # Removes volumes
```

### Mobile Development

**Run in debug mode:**

```bash
flutter run
```

**Hot reload:**

- Press `r` in terminal
- Or save files (auto-reload)

**Build APK:**

```bash
flutter build apk
```

**Run tests:**

```bash
flutter test
```

## 📊 Database Schema

### Goals Table

```sql
goals:
  - id (PK, Integer)
  - user_id (FK, Integer)
  - title (String)
  - description (Text, nullable)
  - completed (Boolean)
  - created_at (Timestamp)
  - updated_at (Timestamp)
```

### Usage Logs Table

```sql
usage_logs:
  - id (PK, Integer)
  - user_id (FK, Integer)
  - app_name (String)          # "TikTok", "Instagram"
  - package_name (String)      # "com.zhiliaoapp.musically"
  - duration (Integer)         # seconds
  - intercepted (Boolean)
  - action_taken (String)      # "allowed_5min", "blocked"
  - timestamp (Timestamp)
```

### Focus Sessions Table

```sql
focus_sessions:
  - id (PK, Integer)
  - user_id (FK, Integer)
  - start_time (Timestamp)
  - end_time (Timestamp, nullable)
  - duration (Integer)         # seconds
  - interrupted (Boolean)
  - created_at (Timestamp)
```

## 🧪 Testing

### Backend Testing

```bash
# Unit tests (coming soon)
pytest

# Test API endpoints
curl http://localhost:8000/
curl http://localhost:8000/goals
```

### Mobile Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/services/api_service_test.dart

# Integration tests
flutter drive --target=test_driver/app.dart
```

## 🐛 Troubleshooting

### Backend Issues

**Port 8000 already in use:**

```bash
# Find and kill process
lsof -ti:8000 | xargs kill -9

# Or change port in docker-compose.yml
ports:
  - "8001:8000"
```

**Database connection failed:**

```bash
# Check database logs
docker-compose logs db

# Restart database
docker-compose restart db

# Wait for health check to pass
```

**Docker build fails:**

```bash
# Clear Docker cache
docker-compose build --no-cache

# Remove old containers
docker-compose down -v
docker system prune -a
```

### Mobile Issues

**Flutter dependencies error:**

```bash
flutter clean
flutter pub get
```

**Android build fails:**

```bash
cd android
./gradlew clean
cd ..
flutter build apk
```

**iOS build fails:**

```bash
cd ios
pod install
cd ..
flutter build ios
```

## 🗺 Roadmap

### Phase 1: MVP (Weeks 1-3) ✅ In Progress

- [x] Backend infrastructure setup
- [x] FastAPI + PostgreSQL + Docker
- [x] Database models & schemas
- [x] Goals API endpoints
- [x] Tracking API endpoints
- [x] Flutter project setup
- [ ] Basic UI screens
- [ ] App monitoring service
- [ ] Interception dialog

### Phase 2: Core Features (Weeks 4-6)

- [ ] Focus mode implementation
- [ ] Timer & notifications
- [ ] Local data caching
- [ ] Statistics dashboard
- [ ] Self-testing for 1 week
- [ ] Bug fixes & optimization

### Phase 3: Enhancement (Weeks 7-9)

- [ ] User authentication
- [ ] Gamification system
- [ ] Data visualization
- [ ] Settings & customization
- [ ] Beta testing

### Phase 4: Polish & Launch (Weeks 10-12)

- [ ] UI/UX improvements
- [ ] Performance optimization
- [ ] App store preparation
- [ ] Documentation
- [ ] Public release

## 🤝 Contributing

This is currently a personal project, but suggestions and feedback are welcome!

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Chihteng Ma**

- Location: Long Island, New York
- Role: Full Stack Developer

## 🙏 Acknowledgments

- Inspired by the need to solve my own procrastination problem
- Built with modern tools: FastAPI, Flutter, PostgreSQL
- Special thanks to the open-source community

## 📞 Contact & Support

- GitHub Issues: [Create an issue](https://github.com/chihtengma416/fomode/issues)
- Email: chihtengma416@gmail.com

---

**Note**: This is an MVP in active development. Features and documentation will be updated as the project progresses.

_Last updated: November 13, 2025_
