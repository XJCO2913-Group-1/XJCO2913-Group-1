from fastapi import APIRouter

from app.api.v1.endpoints import users, auth, scooters, rentals

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(scooters.router, prefix="/scooters", tags=["scooters"])
api_router.include_router(rentals.router, prefix="/rentals", tags=["rentals"])