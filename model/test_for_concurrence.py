import requests
import json
import time
from concurrent.futures import ThreadPoolExecutor

# Flask 服务器地址
URL = "http://bozhiyunyu.cn:3389/qwen"
# 并发请求数
CONCURRENT_REQUESTS = 20

# 请求数据
payload = {"uid": "123", "cid": "123", "status": 0, "query": "我好难受，我老公打我，打我好疼", "history_chat": []}

def send_request(i):
    start_time = time.time()
    completion_time = None
    try:
        with requests.post(URL, json=payload, stream=True) as response:
            if response.status_code == 200:
                for line in response.iter_lines(decode_unicode=True):
                    pass  # 读取所有数据
                completion_time = time.time() - start_time
            return {
                "request_id": i,
                "status_code": response.status_code,
                "completion_time": completion_time
            }
    except Exception as e:
        return {
            "request_id": i,
            "status_code": "ERROR",
            "completion_time": None,
            "error": str(e)
        }

if __name__ == "__main__":
    start = time.time()
    results = []
    
    with ThreadPoolExecutor(max_workers=CONCURRENT_REQUESTS) as executor:
        futures = {executor.submit(send_request, i): i for i in range(CONCURRENT_REQUESTS)}
        for future in futures:
            results.append(future.result())
    
    total_time = time.time() - start
    
    # 计算平均完成时间
    valid_times = [r['completion_time'] for r in results if r['completion_time'] is not None]
    avg_completion_time = sum(valid_times) / len(valid_times) if valid_times else 0
    
    # 打印结果
    print("Total concurrent execution time:", total_time, "seconds")
    print("Average time to complete response:", avg_completion_time, "seconds")
    for result in results:
        print(result)