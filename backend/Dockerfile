FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

COPY .env.prod .env
COPY . .



EXPOSE 8000

#uvicorn app.main:app --host 0.0.0.0 --port 8222
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]