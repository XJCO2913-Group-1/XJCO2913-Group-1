from config.config import *
from langchain_community.vectorstores import Chroma
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_huggingface.embeddings import HuggingFaceEmbeddings
from langchain.schema import Document
import csv

# 初始化 embedding 模型
embed_model = HuggingFaceEmbeddings(
    model_name=EMBEDDING_MODEL_NAME,
    cache_folder=EMBEDDING_MODEL_PATH
)


def init_chroma_model_from_csv(path: str, chunk_size: int, chunk_overlap: int, output_path: str):
    # Step 1: 加载 CSV 中的每一行，作为一个 Document
    documents = []
    with open(path, 'r', encoding='gbk') as f:
        reader = csv.reader(f)
        header = next(reader)  # 跳过表头
        for row in reader:
            # 将整行拼成一个字符串作为一个文档（你也可以只用其中一个字段）
            line_text = " ".join(row).strip()
            if line_text:
                documents.append(Document(page_content=line_text))

    # Step 2: 使用 RecursiveCharacterTextSplitter（每行一般都很短，其实可以不切，但保留逻辑方便拓展）
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=chunk_overlap,
    )
    docs = text_splitter.split_documents(documents)

    # Step 3: 构建 Chroma 向量数据库
    vectorstore_post = Chroma.from_documents(
        documents=docs,
        embedding=embed_model,
        collection_name=COLLECTION_NAME,
        persist_directory=output_path,
    )
    print("finish one of database")


# 调用示例
init_chroma_model_from_csv("./books/data.csv", 2000, 500, PERSIST_DIRECTORY)
