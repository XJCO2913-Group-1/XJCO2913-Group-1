from schema.total_information import TotalInformation
from search_relevant_information_firstly_abc import SearchRelevantInformationFirstlyABC
from config.config import *
from transform_input_to_total_information import TransformInputToTotalInformation
from extract_query import ExtractQuery
import concurrent.futures

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
        # similarity = self.vectorstore.similarity_search_with_relevance_scores(query)
        # if similarity[0][-1] < MIN_SIMILARITY:
        # #compare the min similarity of search results with the setting number.
        #     return []
        results = self.vectorstore.similarity_search(query, k=SEARCH_NUMBER)
        list_of_results=[x.page_content for x in results]
        return list_of_results

    # def remake_relevant_information(self,relevant_information:list[str],query:str) -> str:
    #     summary_information=""
    #     if relevant_information==[]:
    #         return "No relevant information"
    #     index=1
    #     for information in relevant_information:
    #         chatbot_answer_about_summary_information=self.chatbot_used_to_summarize_information(information=information,query=query)
    #         if chatbot_answer_about_summary_information !="":
    #             summary_information = summary_information+"Information "+str(index)+":\n"+chatbot_answer_about_summary_information+"\n"
    #             index=index+1
    #     summary_information=summary_information+"\n"
    #     return summary_information
    def remake_relevant_information(self, relevant_information: list[str], query: str) -> str:
        if not relevant_information:
            return "No relevant information"

        summary_information = ""
        
        def process_information(index, information):
            chatbot_answer_about_summary_information = self.chatbot_used_to_summarize_information(information=information, query=query)
            if chatbot_answer_about_summary_information:
                return f"Information {index}:\n{chatbot_answer_about_summary_information}\n"
            return ""
        
        with concurrent.futures.ThreadPoolExecutor() as executor:
            # Using enumerate to get the index and information
            results = executor.map(process_information, range(1, len(relevant_information) + 1), relevant_information)

        # Concatenate the results
        summary_information = "".join(results)
        return summary_information
    


    def chatbot_used_to_summarize_information(self, information:str, query:str):
        prompt=self.remake_prompt.replace("{information}", information).replace("{query}",query)
        summary_information = self.chat_model_not_stream.ask(prompt,SUMMARY_MODEL_NAME)
        if summary_information["status"] == -1:
            raise Exception(summary_information["answer"])
        if summary_information["answer"] =="N" or summary_information["answer"] =="n":
            return ""
        return summary_information["answer"]
# container=TransformInputToTotalInformation().process({"uid": "123", "cid":"123","status":0,"query": "How is bipolar disorder managed during pregnancy?","history_chat":[]})
# ExtractQuery().process(data=container)
# SearchRelevantInformationFirstly().process(data=container)
# print(container)

            
