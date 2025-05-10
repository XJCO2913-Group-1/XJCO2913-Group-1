from model_abc import ModelABC
from schema.total_information import TotalInformation
class GetAnswerABC(ModelABC):
    def __init__(self):
        super().__init__()
    
    def process(data: TotalInformation):
        pass
