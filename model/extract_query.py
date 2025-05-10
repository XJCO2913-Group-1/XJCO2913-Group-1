from extract_query_abc import ExtractQueryABC
from transform_input_to_total_information import TransformInputToTotalInformation
from schema.total_information import TotalInformation


class ExtractQuery(ExtractQueryABC):
    def __init__(self):
        super().__init__()
    def process(self, data: TotalInformation):
        if data.status == -1:
            return
        try:
            dict_of_remake_query = self.search_relevant_information_and_remake_query(history_chat=data.history_chat,follow_up_question=data.query)
            
            if dict_of_remake_query["status"]==-1:
                data.status = -1                                                                        
                data.append(role=self.role, readout=dict_of_remake_query["answer"])
            else:
               data.append(role=self.role, readout="用户的输入："+data.query+"。上下文信息："+dict_of_remake_query["answer"]+"")
        except Exception as e:
            data.status = -1
            data.append(role=self.role, readout=str(e))

    def search_relevant_information_and_remake_query(self, history_chat: list[str], follow_up_question: str) -> str:
        chat_history = self.format_chat_history(history_chat)
        message = (self.prompt_in_remake_query.replace("{chat_history}", chat_history)).replace("{follow_up_question}",
                                                                                               follow_up_question)
        response = self.chat_model_not_stream.ask(message)

        return response
    
    def format_chat_history(self,history_chat: list[str]) -> str:
        formatted_str = ""
        for i in range(0, len(history_chat), 2):
            question_num = i // 2 + 1
            question = history_chat[i]
            answer = history_chat[i + 1] if i + 1 < len(history_chat) else ""
            formatted_str += f"question {question_num}:{question}\nanswer {question_num}:{answer}\n"
        return formatted_str.strip()
