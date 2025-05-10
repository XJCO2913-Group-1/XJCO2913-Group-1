from model_abc import ModelABC
class SearchRelevantInformationABC(ModelABC):
    def __init__(self):
        super().__init__()
#         self.remake_prompt="""
# **角色**
# 你是一个人工智能助手，可以把一段片段进行改写。
# **能力**
# 您应该总结与“提问”相关的内容，返回的内容应当全面而精简。
# 如果没有发现在片段中的任何信息与“提问”有关，则返回N。
# **提示**
# 直接给出结果。
# 不要解释!

# ###
# 片段:{information}
# ###
# 提问:{query}
# """
        self.remake_prompt="""
你是一个善于判断和总结的语言学家，擅长把“片段”中的和“提问”有关的信息提取出来
### 要求
如果你认为，“片段”和“提问”不相关，那么直接返回N
如果你认为相关，那么就将“片段”中与“提问”有关的内容，用精简的语言表达出来
直接输出你的认为


## 禁止
禁止对提问进行回答

###
片段:{information}
###
提问:{query}
"""
