from get_answer_abc import GetAnswerABC
from schema.total_information import TotalInformation
class GetAnswerFirstlyABC(GetAnswerABC):
    def __init__(self):
        super().__init__()
        self.role="first_replier"
        self.prompt="""
你是某共享电动滑板车平台的智能客服，专门负责回答用户的问题。

请根据以下提供的资料内容，准确、简洁地回复用户的问题。

#### 平台资料：
{information}

#### 用户提问：
{query}

#### 智能客服的回答：

"""
    def process(data: TotalInformation):
        pass
