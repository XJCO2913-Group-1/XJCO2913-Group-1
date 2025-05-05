from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.scooter_price import ScooterPrice
from app.schemas.scooter_price import ScooterPriceCreate, ScooterPriceUpdate


class CRUDScooterPrice(CRUDBase[ScooterPrice, ScooterPriceCreate, ScooterPriceUpdate]):
    def get_by_model(self, db: Session, *, model: str) -> ScooterPrice | None:
        return db.query(ScooterPrice).filter(ScooterPrice.model == model).first()


scooter_price = CRUDScooterPrice(ScooterPrice)
