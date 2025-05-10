from flask import Flask, request, Response, jsonify, stream_with_context
from server import chat_bot
import json

app = Flask(__name__)

@app.route('/qwen', methods=['POST'])
def chatbot():
    input_data = request.json  # 期望接收 JSON 输入
    if not input_data:
        return jsonify({"error": "Invalid input"}), 400

    def generate():
        for response in chat_bot(input_data):
            resp = json.dumps(response, ensure_ascii=False) + '\n'  # 设置 ensure_ascii=False
            yield f"data:{resp}\n"

    # 使用 NDJSON 格式，调整 Content-Type
    return Response(stream_with_context(generate()), content_type='text/event-stream')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3389,threaded=True)

