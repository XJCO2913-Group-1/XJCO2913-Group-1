from get_answer_firstly_abc import GetAnswerFirstlyABC
from schema.total_information import TotalInformation
class GetAnswerFirstly(GetAnswerFirstlyABC):
    def __init__(self):
        super().__init__()
    
    def process(self,data: TotalInformation):
        if data.status == -1:
            return data.process_data[-1].readout
        try:
            for i in data.process_data:
                if i.role=="extracter":
                    remake_query=i.readout
            total_answer = self.chatbot(query=data.query,information=data.process_data[-1].readout,history_chat=data.history_chat)                                                            
            for i in total_answer:
                yield i 
        except Exception as e:
            data.status = -1
            return e
        

    def chatbot(self,query:str,information:str,history_chat):
        prompt=self.prompt.replace("{information}", information).replace("{query}",query)
        final_answer = self.chat_model_stream.ask(prompt,history_chat)
        for i in final_answer:
            if i["status"]==-1:
                raise Exception(i["answer"])
            yield i["answer"]
