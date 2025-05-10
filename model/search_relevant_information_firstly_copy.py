from schema.total_information import TotalInformation
from search_relevant_information_firstly_abc import SearchRelevantInformationFirstlyABC
from config.config import *
from transform_input_to_total_information import TransformInputToTotalInformation
from extract_query import ExtractQuery
class SearchRelevantInformationFirstly(SearchRelevantInformationFirstlyABC):
    def __init__(self):
        super().__init__()

    def process(self, data: TotalInformation) -> None:
        if data.status == -1:
            return
        try:
            remake_query = data.process_data[-1].readout
            data.append(role=self.role, readout=self.search_relevant_information_and_remake_query(query=remake_query))
        except Exception as e:
            data.status = -1
            data.append(role=self.role, readout=str(e))

    def search_relevant_information_and_remake_query(self,query:str) -> str:
        return self.remake_relevant_information(relevant_information=self.search_relevant_information(query=query),query=query)
        

    
    def search_relevant_information(self,query:str) -> list[str]:
        similarity = self.vectorstore.similarity_search_with_relevance_scores(query)
        if similarity[0][-1] < MIN_SIMILARITY:
        #compare the max similarity of search results with the setting number.
            return []
        results = self.vectorstore.similarity_search(query, k=SEARCH_NUMBER)
        list_of_results=[x.page_content for x in results]
        return list_of_results

    def remake_relevant_information(self,relevant_information:list[str],query:str) -> dict:
        summary_information=""
        if relevant_information==[]:
            return {"status":0,"answer":"No relevant information"}
        index=1
        for information in relevant_information:
            chatbot_answer_about_summary_information=self.chatbot_used_to_summarize_information(information=information,query=query)
            if chatbot_answer_about_summary_information["status"] == -1:
                return {"status":-1,"answer":chatbot_answer_about_summary_information["answer"]}
            if chatbot_answer_about_summary_information["status"] != 0:
                summary_information = summary_information+"Information "+str(index)+":\n"+chatbot_answer_about_summary_information["status"]+"\n"
                index=index+1
        summary_information=summary_information+"\n"
        return {"status":1,"answer":summary_information}
    


    def chatbot_used_to_summarize_information(self, information:str, query:str) -> dict:
        prompt=self.remake_prompt.replace("{information}", information).replace("{query}",query)
        summary_information = self.chat_model_not_stream.ask(prompt)
        if summary_information["answer"] =="N" or summary_information["answer"] =="n":
            return {"status":0,"answer":""}
        return summary_information
# container=TransformInputToTotalInformation().process({"uid": "123", "cid":"123","status":0,"query": "How is bipolar disorder managed during pregnancy?","history_chat":[]})
# ExtractQuery().process(data=container)
# SearchRelevantInformationFirstly().process(data=container)
# print(container)

            