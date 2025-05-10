from search_relevant_information_abc import SearchRelevantInformationABC
from schema.total_information import TotalInformation
class SearchRelevantInformationFirstlyABC(SearchRelevantInformationABC):
    def __init__(self):
        super().__init__()
        self.role="first_searcher"
        
    
    def process(data: TotalInformation) -> None:
        pass
