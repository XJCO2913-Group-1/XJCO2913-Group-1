# Electric Scooter Rental Platform Backend Service

## Tech Stack

- Python
- FastAPI
- PostgreSQL
- Docker

## Project Structure

```bash
├── alembic/          # Database migration files
├── app/              # Main application directory
│   ├── api/          # API routes
│   ├── core/         # Core configuration
│   ├── db/           # Database configuration
│   ├── models/       # Database models
│   └── schemas/      # Pydantic models
├── tests/            # Test directory
│   ├── integration/  # Integration tests
│   └── unit/         # Unit tests
└── docker-compose.yml
```

## Development Environment Setup

1. Clone the repository
2. Create and activate a virtual environment
3. Install dependencies: `pip install -r requirements.txt`
4. Copy `.env.example` to `.env` and configure environment variables
5. Start the development server: `uvicorn app.main:app --reload`

## Database Migration

- Create a migration: `alembic revision --autogenerate -m "migration message"`
- Apply the migration: `alembic upgrade head`

## Testing

The project uses pytest for testing. Test files are located in the `tests` directory:

- `unit/`: Unit tests, testing isolated components
- `integration/`: Integration tests, testing API endpoints

Run the tests:

```bash
pytest
```

## API Documentation

After starting the server, auto-generated API documentation is available at:

- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Docker Deployment

Use Docker Compose to start the service:

```bash
docker-compose up -d
```

## Development Guidelines

1. Follow PEP 8 coding standards
2. All new features must include tests
3. Use black for code formatting
4. Run tests and ensure all pass before committing

## License

MIT
