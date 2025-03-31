# Import all schemas here for easy access
from .token import Token, TokenPayload
from .user import User, UserCreate, UserUpdate, UserInDB
from .scooter import Scooter, ScooterCreate, ScooterUpdate
from .rental import Rental, RentalCreate, RentalUpdate
from .rental_config import RentalConfig, RentalConfigCreate, RentalConfigUpdate
from .payment_card import PaymentCard, PaymentCardCreate, PaymentCardUpdate
from .payment import Payment, PaymentCreate, PaymentUpdate, PaymentStatus, PaymentMethod, PaymentConfirmation
from .feedback import Feedback, FeedbackCreate, FeedbackUpdate, FeedbackStatus, FeedbackType, FeedbackInDBBase, FeedbackTypeOption, FeedbackTypeOptions,FeedbackWithDetails

__all__ = ["User", "Rental", "Scooter", "rental_config", "PaymentCard", "Payment", "PaymentConfirmation", "Feedback"]