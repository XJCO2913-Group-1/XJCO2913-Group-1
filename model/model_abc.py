from config.config import *
from langchain_huggingface.embeddings import HuggingFaceEmbeddings
from qwen_chat_api_not_stream import QwenChatAPINotStream
from qwen_chat_api_stream import QwenChatAPIStream
from langchain.vectorstores import Chroma
class ModelABC:
    def __init__(self):
        super().__init__()
        self.chat_model_not_stream = QwenChatAPINotStream()
        self.chat_model_stream=QwenChatAPIStream()
        self.embedding_model = HuggingFaceEmbeddings(
            model_name=EMBEDDING_MODEL_NAME,
            cache_folder=EMBEDDING_MODEL_PATH
        )
        self.vectorstore = Chroma(
            persist_directory=PERSIST_DIRECTORY, 
            embedding_function=self.embedding_model,
            collection_name=COLLECTION_NAME
        )
        #在未来的项目中，可以通过在这里添加矢量数据库的变量的方法实现多数据库检索。本项目只考虑到了一个矢量数据库。

