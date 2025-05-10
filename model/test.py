import requests
import json

# 请求 URL
url = "http://119.45.26.22:3389/qwen"

# 需要请求的 query 列表
queries = [
    "我可以选择几种不同时间"
]

# 请求头
headers = {
    "Content-Type": "application/json"
}

# 发起多个 POST 请求
for query in queries:
    data = {
        "uid": "123",
        "cid": "123",
        "status": 0,
        "query": query,
        "history_chat": []
    }

    response = requests.post(url, data=json.dumps(data), headers=headers, stream=True)

    # 设置正确的编码格式
    response.encoding = 'utf-8'  # 显式设置编码为 UTF-8

    # 检查响应状态码
    if response.status_code == 200:
        full_answer = ""
        
        # 逐行读取流式响应
        for line in response.iter_lines(decode_unicode=True):
            if line:
                # 确保按 'data:' 解析每个部分的响应
                if line.startswith("data:"):
                    try:
                        # 获取JSON数据并拼接
                        json_data = line[5:].strip()  # 移除 'data:' 前缀
                        response_data = json.loads(json_data)
                        answer = response_data.get("answer", "")
                        full_answer += answer  # 拼接每个部分
                    except json.JSONDecodeError as e:
                        print(f"Failed to decode JSON: {e} - {line}")
        
        # 打印完整回答
        print(f"Complete answer for query '{query}':\n{full_answer}")

    else:
        print(f"Request for query '{query}' failed with status code {response.status_code}. Response: {response.text}")

