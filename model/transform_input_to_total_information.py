from schema.total_information import TotalInformation


class TransformInputToTotalInformation:
    def process(self, Input: dict):
        if not isinstance(Input, dict):
            raise TypeError("Input should be a dict")
        # 检查 status 是否为整数类型
        if not isinstance(Input.get('status'), int):
            raise TypeError("Invalid type for 'status': expected int")
        
        # 检查 uid 和 cid 是否为字符串类型
        if not isinstance(Input.get('uid'), str):
            raise TypeError("Invalid type for 'uid': expected str")
        
        if not isinstance(Input.get('cid'), str):
            raise TypeError("Invalid type for 'cid': expected str")
        
        # 检查 query 是否为字符串类型
        if not isinstance(Input.get('query'), str):
            raise TypeError("Invalid type for 'query': expected str")
        
        # 检查 history_chat 是否为字符串列表
        history_chat = Input.get('history_chat')
        if not isinstance(history_chat, list) or not all(isinstance(item, str) for item in history_chat):
            raise TypeError("Invalid type for 'history_chat': expected list of str")
    
    # 如果所有检查都通过，输入是合法的
        container = TotalInformation(status=0, uid=Input["uid"],cid=Input["cid"], query=Input["query"],history_chat=Input["history_chat"])
        return container


# a = TransformInputToTotalInformation().process({"uid": "123", "cid":"123","status":0,"query": "21","history_chat":[]})
# print(a)