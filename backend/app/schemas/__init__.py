# Import all schemas here for easy access
from .token import Token, TokenPayload
from .user import User, UserCreate, UserUpdate, UserInDB
from .scooter import Scooter, ScooterCreate, ScooterUpdate,Coordinates
from .rental import Rental, RentalCreate, RentalUpdate
from .rental_config import RentalConfig, RentalConfigCreate, RentalConfigUpdate
from .payment_card import PaymentCard, PaymentCardCreate, PaymentCardUpdate
from .payment import Payment, PaymentCreate, PaymentUpdate, PaymentStatus, PaymentMethod, PaymentConfirmation
from .feedback import Feedback, FeedbackCreate, FeedbackUpdate, FeedbackStatus, FeedbackType, FeedbackTypeOption, FeedbackTypeOptions,FeedbackWithDetails
from .revenue_stats import RevenueStats, RevenueSummary, RevenueQueryParams, RevenuePeriodStats ,RevenueStatsCreate, RevenuePeriodData

__all__ = ["User", "Rental", "Scooter", "RentalConfig", "PaymentCard", "Payment", "PaymentConfirmation", "Feedback", "Revenue"]