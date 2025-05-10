# Electric Scooter Rental Platform Backend Service

## 技术栈

- Python
- FastAPI
- PostgreSQL
- Docker

## 项目结构

```
.
├── alembic/          # 数据库迁移文件
├── app/              # 应用主目录
│   ├── api/          # API路由
│   ├── core/         # 核心配置
│   ├── db/           # 数据库配置
│   ├── models/       # 数据库模型
│   └── schemas/      # Pydantic模型
├── tests/            # 测试目录
│   ├── integration/  # 集成测试
│   └── unit/        # 单元测试
└── docker-compose.yml
```

## 开发环境设置

1. 克隆仓库
2. 创建并激活虚拟环境
3. 安装依赖：`pip install -r requirements.txt`
4. 复制`.env`到`.env`并配置环境变量
5. 启动开发服务器：`uvicorn app.main:app --reload`

## 数据库迁移

- 创建迁移：`alembic revision --autogenerate -m "migration message"`
- 应用迁移：`alembic upgrade head`

## 测试

项目使用pytest进行测试。测试文件位于`tests`目录下：
- `unit/`: 单元测试，测试独立组件
- `integration/`: 集成测试，测试API端点

运行测试：
```bash
pytest
```

## API文档

启动服务器后，可以在以下地址访问自动生成的API文档：
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Docker部署

使用Docker Compose启动服务：
```bash
docker-compose up -d
```

## 开发指南

1. 遵循PEP 8编码规范
2. 所有新功能都需要添加测试
3. 使用black进行代码格式化
4. 提交前运行测试确保全部通过

## 许可证

MIT
