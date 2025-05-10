import requests
import json
from openai import OpenAI
from config.config import *
class QwenChatAPIStream:
        # Input: 
    # query:str
    # Output:
    # {
    #     status:int,
    #     answer:str
    # }

    def ask(self, query: str,history_chat:list[str],model_name=QWEN_CHAT_MODEL_NAME):
        # 构造请求的payload
        messages=[{'role': 'system', 'content': SYSTEM_PROMPT}]
        for i,content in enumerate(history_chat):
            if i % 2 ==0:
                messages.append({'role': 'user', 'content': content})
            else:
                messages.append({'role': 'assistant', 'content': content})
        messages.append({'role': 'user', 'content': query})
        client = OpenAI(
            # 若没有配置环境变量，请用百炼API Key将下行替换为：api_key="sk-xxx",
            api_key=QWEN_CHAT_MODEL_API_KEY,
            base_url=QWEN_CHAT_MODEL_BASE_URL,
        )

        try:
            
            completion = client.chat.completions.create(
                model=model_name,
                messages=messages,
                stream=True,
                stream_options={"include_usage": True}
                )
            for chunk in completion:
                data=json.loads(chunk.model_dump_json())
                if data["choices"]!=[]:
                    message_content=data["choices"][-1]["delta"]["content"]     
                    yield {"status":0,"answer":message_content}
                        

        except requests.exceptions.RequestException as e:
            # 处理请求异常
            yield {"status":-1,"answer":str(e)}
