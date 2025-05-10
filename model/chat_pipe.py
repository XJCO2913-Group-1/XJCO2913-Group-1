from chat_pipeline import ChatPipeline
from extract_query import ExtractQuery
from search_relevant_information_firstly import SearchRelevantInformationFirstly
from get_answer_firstly import GetAnswerFirstly
from schema.total_information import TotalInformation
from transform_input_to_total_information import TransformInputToTotalInformation


class ChatPipe:
    def __init__(self):
        self.chat_step = ChatPipeline()
        self.chat_step.add_process(ExtractQuery())
        self.chat_step.add_process(SearchRelevantInformationFirstly())
    def process(self, data: TotalInformation):
        self.chat_step.process(data)
        return data
        # data.get_result()
# container = TotalInformation(id="1", query="I can't understand yet.Geive me more detail")
#
# print(ChatPipe().process(container))
