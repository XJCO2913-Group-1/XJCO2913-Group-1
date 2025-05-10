import json
from openai import OpenAI
from config.config import *
class QwenChatAPINotStream:
    # Input: 
    # query:str
    # Output:
    # {
    #     status:int,
    #     answer:str
    # }
    def __init__(self, base_url: str = "http://localhost:11434/api/chat"):
        self.base_url = base_url

    def ask(self, query: str,model_name=QWEN_CHAT_MODEL_NAME):
        # 构造请求的payload
        client = OpenAI(
        # 若没有配置环境变量，请用百炼API Key将下行替换为：api_key="sk-xxx",
        api_key=QWEN_CHAT_MODEL_API_KEY, 
        base_url=QWEN_CHAT_MODEL_BASE_URL,
        )
        
        try:
            # 发送POST请求到指定URL
            completion = client.chat.completions.create(
            model=model_name, # 模型列表：https://help.aliyun.com/zh/model-studio/getting-started/models
            messages=[
                {'role': 'system', 'content': ''},
                {'role': 'user', 'content': query}],
            )

            # 解析JSON响应
            response_data = (json.loads(completion.model_dump_json()))["choices"][-1]["message"]["content"]
            
            # 从响应中提取答案
            return {"status":0,"answer":response_data}

        except Exception as e:
            return {"status":-1,"answer":str(e)}

# a=QwenChatAPINotStream()
# print(a.ask("你是谁"))


