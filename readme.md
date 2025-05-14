# Easy Scooter Shared Scooter Rental Platform

<img src="frontend/assets/images/black_on_white.png" alt="Easy Scooter Logo" width="300">

## Group members
Bowen Ye (叶博文): Scrum master
Guocheng He (何国诚): Test engineer + Database engineer
Hongrui Zhang (张洪瑞): Frontend engineer
Tongyu Wu (吴桐宇): Backend engineer
Lirong Guo (郭力榕): Document engineer

## 1. Features

Easy Scooter is an intelligent rental management platform designed for family-style shared scooter shops. The platform integrates modern mobile applications, backend services, and intelligent customer service systems, providing a complete digital solution for small scooter rental shops.

### Project Overview

The Easy Scooter platform aims to help small scooter rental shops achieve digital transformation, improving operational efficiency and user experience through an intelligent management system. The platform supports multi-platform access, including mobile apps (Android/iOS), web version, and desktop version (Windows), meeting usage requirements in different scenarios.

### Application Scenarios

- Family-style scooter rental shops
- Small shared scooter operators
- Tourist attraction scooter rental services
- Campus scooter sharing services

### Interface Showcase

#### Login Interface
<img src="frontend/assets/images/screem%20shot/log_in.png" alt="Login Interface" width="400">

#### Main Map Interface
<img src="frontend/assets/images/screem%20shot/main_edge.png" alt="Main Map" width="400">

#### Personal Center Interface
<img src="frontend/assets/images/screem%20shot/self_edge.png" alt="Personal Center" width="400">

#### Intelligent Customer Service Chat Interface
<img src="frontend/assets/images/screem%20shot/llm_answering.png" alt="Intelligent Customer Service" width="400">

> Note: The following interface screenshots are pending:
> 1. Scooter Details Interface
> 2. Payment Interface

### Core Features

#### 🛴 Scooter Management
- Real-time scooter location tracking
- Scooter status monitoring (available, in use, maintenance)
- Scooter rating and review system
- Intelligent dispatch and allocation

#### 💳 Payment System
- Multiple payment card management
- Secure payment card storage
- Default card settings
- Payment verification and confirmation
- Automatic billing and settlement

#### 👤 User Management
- User registration and login
- Personal information management
- Avatar upload and compression
- Local data synchronization
- User credit rating

#### 📝 Rental Management
- Create and manage rental records
- View rental history
- Real-time rental status tracking
- Fee calculation and payment processing
- Automatic renewal reminders

#### 💬 Intelligent Customer Service
- Real-time chat interface
- Intelligent Q&A
- User guides and tips
- Message history management
- Multi-language support (Chinese, English)

#### 📱 Other Features
- QR code scanning for unlocking
- Location-based services
- Device permission management
- Multi-language support
- Real-time notification system

## 2. Project Structure (Partial)

```
├── frontend/                # Flutter frontend application
│   ├── lib/                # Main source code
│   │   ├── components/     # Reusable UI components
│   │   ├── models/        # Data models
│   │   ├── pages/         # Application pages
│   │   ├── providers/     # State management
│   │   ├── services/      # API services
│   │   └── utils/         # Utility functions
│   ├── test/              # Test files
│   └── assets/            # Resource files
│
├── backend/               # FastAPI backend service
│   ├── app/              # Main application directory
│   │   ├── api/          # API routes
│   │   ├── core/         # Core configuration
│   │   ├── db/           # Database configuration
│   │   ├── models/       # Database models
│   │   └── schemas/      # Data validation
│   ├── tests/            # Test files
│   └── alembic/          # Database migrations
│
└── model/                # Intelligent customer service system
    ├── config/           # Configuration files
    ├── schema/           # Data schemas
    └── chroma_database/  # Vector database
```

## 3. How to Start

### Frontend Startup

1. Install Flutter SDK (>=2.19.4)
2. Enter frontend directory:
```bash
cd frontend
```
3. Install dependencies:
```bash
flutter pub get
```
4. Run the application:
```bash
# Development mode
flutter run

# Release mode
flutter run --release

# Windows version
flutter run -d windows

# Web version
flutter run -d chrome
```

### Backend Startup

1. Install Python 3.8+
2. Enter backend directory:
```bash
cd backend
```
3. Create virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows
```
4. Install dependencies:
```bash
pip install -r requirements.txt
```
5. Configure environment variables (copy .env.example to .env and modify)
6. Start service:
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8222
```

### Using Docker (Recommended)

1. Install Docker and Docker Compose
2. Run in backend directory:
```bash
docker-compose up -d
```

### Intelligent Customer Service Startup

1. Enter model directory:
```bash
cd model
```
2. Create virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate     # Windows
```
3. Install dependencies:
```bash
pip install -r requirements.txt
```
4. Configure Qwen API key (in config/config.py)
5. Start service:
```bash
python server.py
```

## 4. How to Verify Successful Startup

### Frontend Verification
1. After successful startup, the login interface will be displayed
2. Check if the following functions are working:
   - User registration/login
   - Scooter list loading
   - Map display
   - QR code scanning
   - Payment function

### Backend Verification
1. Access API documentation:
   - Swagger UI: http://localhost:8222/docs
   - ReDoc: http://localhost:8222/redoc
2. Check health status:
   - Access http://localhost:8222/api/v1/health
   - Should return {"status": "healthy"}

### Database Verification
1. Check database connection:
   - Use psql to connect to database (port 5438)
   - Username: postgres
   - Password: password
   - Database name: rental_platform

### Intelligent Customer Service Verification
1. Access customer service API:
   - Endpoint: http://119.45.26.22:3389/qwen
2. Send test message to verify response:
```json
{
  "uid": "test_user",
  "cid": "test_conversation",
  "status": 0,
  "query": "Hello",
  "history_chat": []
}
```

### Complete Function Verification Checklist
- [ ] User registration and login
- [ ] Scooter list display
- [ ] Map location function
- [ ] Payment system
- [ ] Rental process
- [ ] Intelligent customer service response
- [ ] Real-time notifications
- [ ] Data synchronization

If all the above check items pass, it indicates that the system has been successfully started and is running normally.