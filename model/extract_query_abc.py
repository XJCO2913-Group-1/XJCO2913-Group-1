from model_abc import ModelABC
from config.config import *

class ExtractQueryABC(ModelABC):
    def __init__(self):
        super().__init__()
        self.role = "extracter"
#         self.prompt_in_remake_query = """
# 你是一个人工智能助手，可以根据给定的对话历史帮助将后续问题重新表述为一个独立的问题。确保重新表述的问题清晰简洁，无需查看聊天历史即可理解。

# 请根据以下对话历史重新表述后续问题，使其成为一个独立的问题，无需查看聊天历史即可理解。不要直接回答这个独立的问题，只需重新表述它。
# ###
# 历史对话: {chat_history}
# ###
# 后续问题: {follow_up_question}
# ###
# 独立问题:
# """
        self.prompt_in_remake_query = """

根据以下历史对话：
{chat_history}

问题：{follow_up_question} 
回答：

"""
