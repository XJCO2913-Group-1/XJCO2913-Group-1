EMBEDDING_MODEL_NAME='moka-ai/m3e-base' #嵌入模型名字
EMBEDDING_MODEL_PATH="./huggingface_embedding" # 嵌入模型相对地址
PATH_CHROMA = "../chroma/data_QA"  #相对于使用的py文件来定位
SEARCH_NUMBER = 2  #选择几个相关的片段
MIN_SIMILARITY = -130  #判断相似度是否达标的分界线
PERSIST_DIRECTORY = "./chroma_database" #Chroma数据库相对于main脚本的位置
COLLECTION_NAME = "huggingface_embed" #使用哪个平台的embedding模型。
QWEN_CHAT_MODEL_API_KEY=""
QWEN_CHAT_MODEL_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1"
QWEN_CHAT_MODEL_NAME="qwen-turbo"
# QWEN_CHAT_MODEL_NAME="qwen-7b-chat"
SUMMARY_MODEL_NAME="qwen-max"
SYSTEM_PROMPT='''
你是一个AI助手。
'''

