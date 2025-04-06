from fastapi import APIRouter

from app.api.v1.endpoints import users, auth, scooters, rentals, rental_configs, payments, payment_cards, feedbacks, revenue_stats

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(scooters.router, prefix="/scooters", tags=["scooters"])
api_router.include_router(rentals.router, prefix="/rentals", tags=["rentals"])
api_router.include_router(rental_configs.router, prefix="/rental-configs", tags=["rental_configs"])
api_router.include_router(payments.router, prefix="/payments", tags=["payments"])
api_router.include_router(payment_cards.router, prefix="/payment-cards", tags=["payment_cards"])
api_router.include_router(feedbacks.router, prefix="/feedbacks", tags=["feedbacks"])
api_router.include_router(revenue_stats.router, prefix="/revenue-stats", tags=["revenue_stats"])