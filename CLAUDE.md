# Fomode - Project Outline

## 📋 Project Overview

### Problem Definition

Many people (including myself) know what exactly what meaningful things they should be doing (studying, coding practice, working), but time unconsciously gets consumed by entertainment apps on their phones (TikTok, Instagram, Youtube, etc.). Traditional to-do list don't solve this problem because the core issue isn't "not knowing what to do" - it's "knowing what to do but unable to do it."

### Solution

Develop a proactive intervention-based focus app that helps users overcome provrastination through:

1. **Smart Interception** - Actively intervene when users open time-wasting apps
2. **Friction Design** - Turn unconsicous habits into conscious choices
3. **Focus Mode** - Transform the phone into a "learning device," blocking entertainment distractions
4. **Gamified Feedback** - Provide immediate postitive feedback to counter procrastination inertia

---

## 🎯 Core Features

### MVP v0.1 (Week 1 - 2)

**Goal: Solve my own phone scrolling problems**

- Input 1-3 specific goals (e.g., "Solve 10 LeetCode problems", "Study System Design for 1 hour")
- Display today's completion progress
- Simple checkbox interaction

#### 2. App Usage Monitoring + Smart Interception

- Monitor usage of "time-killer" apps
    - iOS: TikTok, Instagram, Youtube, RedNote, etc.
    - Android: Corresponding apps name.
- When user opens these apps, showing interception dialog:
    ```
    " Wait! Are you sure you want to open [App Name]?"
    [Take 5-min break] [Accidentally opened, close]
    ```
- If selecting "Take 5-min break":
    - Start a 5-minute timer
    - Force reminder when time is up (notification + optional force close)
- Record daily usage statistics for self-awareness

#### 3. Focus Mode

- One-tap enable/disable focus mode
- When enabled:
    - Directly block time-killer apps (no choices given)
    - Only allow study tools (timer, notes, browser, etc.)
- Display current focus duration
- Attempting to open blocked app during focus mode -> Show "Focusing! Keep going!"

#### 4. Basic Statistics

- Today's phone scrolling time
- Today's focus time
- Goal completion status

### Future (v0.2+)

#### Gamification System

- Complete goals/focus time -> Earn points
- Points can "purchase" extra entertainment time or unlock features
- Consecutive goal completion -> Unlock achievement badges
- Level System

#### Advanced Features

- AI analyzes procrastination patterns, provides personalized suggestions
- Pomodoro Technique intergration
- Calendar and task management tool intergration
- Data visualization (weekly/monthly reports)
- Custom interception rules
- Social sharing of achievements
- Community challenges and leaderboards

## 🛠️ Tech Stack

### Frontend - Flutter

**Why Flutter:**

- Good performance, smooth UI
- Cross-platform (iOS + Android)
- I have foundational knowledge, can improve while building
- Rich ecosystem for mobile development
- Easy to extend to Web later if needed

** Dependencies:**

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  provider

  # Networking
  http
  dio

  # Local storage
  shared_preferences

  # Platform features
  app_usage # For monitoring app usage (Platform: iOS)
  device_apps # Get install apps (Platform: Android)

  # UI components
  flutter_slidable
  percent_indicator

  # Utils
  intl  # Date formatting
```

### Backend - FastAPI + PostgreSQL

**Why FastAPI:**

- Lightweight, fast, modern
- Built-in async, great performance
- Auto-generated API docs (Swagger UI)
- Type checking + Pydantic validation
- Don't need Django's heavyweight features for this project

**Tech Stacks:**

```
FastAPI         # Web framework
SQLAlchemy      # ORM
PostgreSQL      # Database
Pydantic        # Data validation
Uvicorn         # ASGI server
Alembic         # Database migrations
```

### Dev Tools

- **API Testing**: Postman / Thunder Client
- **Version Control**: Git + GitHub
- ** Containerization**: Docker (optional for deployment)

## 📁 Project Structure

```
anti-procrastination/
|-- README.md
|-- CLAUDE.md               # This document
|
|-- mobile/                 # Flutter app
|   |-- lib/
|   |   |-- main.dart       # Entry point
|   |   |-- models/         # Data models
|   |   |-- screens/        # UI screens
|   |   |-- widgets/        # Reusable UI components
|   |   |-- services/       # Business Logics (API calls, local storage)
|   |   |-- providers/      # State management
|   |   |-- utils/          # Utility functions
|   |-- pubspec.yaml        # Flutter dependencies
|   |-- android/            # Android-specific code
|   |-- ios/                # iOS-specific code
|   |-- assets/             # Images, icons, etc.
|
|-- backend/                # FastAPI backend
|   |-- app/
|   |   |-- main.py         # Entry point
|   |   |-- database.py     # Database configuration
|   |   |-- models/         # SQLAlchemy models
|   |   |-- schemas/        # Pydantic schemas
|   |   |-- routers/        # API routes
|   |   |-- services/       # Business logic (e.g., user management, stats)
|   |   |-- core/           # Core utilities (e.g., authentication, config)
|-- alembic/                # Database migrations
|-- requirements.txt        # Python dependencies
|--.env                     # Environment variables
|-- Dockerfile              # For containerization
|-- docker-compose.yml      # For local development
```

---

## 🗓 Development Roadmap

### Week 1: Backend Foundation

- [x] Project initialization
- [ ] Setup FastAPI + PostgreSQL
- [ ] Implement database models
- [ ] Implement user registration and authentication
- [ ] Implement APIs
    - User management (register, login, profile)
    - Goal management (create, read, update, delete)
    - App usage tracking (record usage, get stats)
- [ ] Write and test API endpoints
- [ ] Setup Docker for backend

### Week 1-2: Flutter Foundation

- [ ] Flutter project initialization
- [ ] Setup project structure
- [ ] Implement API Service
- [ ] Implement basic UI
    - Home Screen (goal list)
    - Focus Screen (focus mode)
    - Stats Screen (statistics)
- [ ] Implement state management (Provider)

### Week 2: Core features

- [ ] Implement App monitoring functionality
    - Android: UsageStatsManager
    - iOS: Screen Time API (requires user authorizatio)
- [ ] Implement interception dialog
- [ ] Implement countdown functionality
- [ ] Implement notification functionality
- [ ] Integrate frontend and backend

### Week 2 - 3: Testing & Optimization

- [ ] Self-testing for all features
- [ ] Fix bugs
- [ ] Optimize UI/UX
- [ ] Performance optimization

### Week 3+: v0.2+ Features

- [ ] Gamification features
- [ ] Data visualization
- [ ] Social features (sharing, leaderboards)
- [ ] AI-powered suggestions
- [ ] Calendar/task management integration
- [ ] Pomodoro technique integration
- [ ] Custom interception rules
- [ ] Community features
- [ ] Web version (Flutter Web)

---

## 📱 User Experience Flow

### First Time Usage

1. Download and install App
2. Open App -> Onboarding screens
    - Welcome message
    - Explanation of features
    - Permission requests (app usage access, notifications)
3. Create account for login
4. Select "time-killer" apps to monitor
5. Create first daily goal
6. Start using the app

### Daily usage

**_Scenario 1: Setting Goals_**

```
Morning open app -> Input today's goal -> Start the date
```

**Scenario 2: Being Intercepted**

```
Want to scroll TikTok -> Open TikTok -> Interception dialog appears ->
    Option 1: "Take 5-min break" -> 5-min countdown -> Time's up reminder
    Option 2: "Accidentally openeed" -> Close Tiktok -> Return to app
```

**Scenario 3: Focus Mode**

```
Need to study -> Open app -> Enable Focus Mode -> Try to open TikTok -> Direct block -> Shows "Focusing! XX minutes remaining" -> Continue studying
```

**Scenario 4: View Statistics**

```
Evening -> Check today's data ->
    "Focus for 3 hours today"
    "Intercepted 5 phone-scrolliung urges"
    "Completed 2/3 goals"
```

---

## 🎨 UI/UX Design Principles

### Desgin Philosohpy

- **Simplicity First**: No fancy animations, focus on functionality
- **Quick Actions**: All core functions accessible within 3 seconds
- **Positive Feedbacks**: Use encouraging language, avoid blaming language
- **Non-intrusive**: Don't annoy users during interception, make them aware of their choices

### Color Scheme

- Primary: Calm blue/green (focus, productivity)
- Warning: Gentle orange (interception reminder)
- Success: Green (goal completion)

### Copywriting Style

- ❌ "You're scrolling your phone again!" (blaming)
- ✅ "Wait, do you want to take a break or did you accidentally open this?" (encouraging)

---

## 🔐 Privacy & Security

### Data Collection

- **Collected**: Goal content, app usage duration, interception records
- **NOT collected**: Specific browsing content within apps, chat records, personal identifiable information (beyond username/email)

### Data Storage

- Local data encrypted storage
- Backend database encrypted
- Users can export/delete their data anytime

### API Security

- Rate limiting
- Input validation
- SQL injection prevention (via SQLAlchemy)
- HTTPS only in production

---

## 🎯 Success Metrics (How to measure if this works)

### For MVP:

- **Personal validation**: Do I acutally use it for 1+ week? and does it help me reduce phone scrolling?
- **Behavior change**: Did my daily phone scrolling time descrease?
- **Goal completion**: Am I completing more daily goals?

### For v0.2+:

- Daily Active Users (DAU)
- Average focus time per user
- Interception acceptance rate
- Goal completion rate
- User retention (7-dayl, 30-day)

--

## 💡 Key Insights & Lessons

### What makes this different from existing apps?

1. **Active intervention** vs passive tracking
2. **Friction desgin** vs simple reminders
3. **Focuses on the moment of temtation** rather than planning
4. **Built for my specific use case** (not trying to be everything for everyone)

### Why this might work?

- Addresses the exact moment when I'm about to procrastinate
- Makes unconscious habit into conscious choices
- Provides immediate feedback loop
- Solves my own problem (dogfooding)

### Potential pitfalls to avoid:

- Making it too annoying (users will uninstall)
- Over-engineering before validating
- Trying to build too many features at once
- Not using it myself consistently

---

## 📚 Resources & References

### Flutter Learning

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

### FastAPI Learning

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SQLAlchemy Tutorial](https://docs.sqlalchemy.org/en/14/tutorial/)

### Similar Apps (Inspiration)

- Forest (gamified focus)
- Freedom (app blocking)
- Habitica (gamified habits)
- One Sec (friction for social media)

### Research

- ["The Power of Habit" by Charles Duhigg](https://charlesduhigg.com/the-power-of-habit/)
- ["Atomic Habits" by James Clear](https://jamesclear.com/atomic-habits)
- [Behavioral Design principles](https://behavioralscientist.org/)

---

## 🤔 Open Questions

1. **Monetization** (future):
    - Free with ads?
    - Freemium model?
    - One-time purchase?
    - Subscription?

2. **Platform prioirty**:
    - iOS first (more restrictive, but more impactful)?
    - Android first (easier to implement monitoring)?

3. **Force closing**:
    - Is force-closing apps too aggressive?
    - Should it be optional?

4. **Privacy concerns**:
    - How much data should we collect?
    - Sould tracking be optional?
