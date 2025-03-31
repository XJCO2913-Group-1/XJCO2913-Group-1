from typing import Any, Dict, List, Optional, Union
import os
from base64 import urlsafe_b64encode
from pydantic import AnyHttpUrl, PostgresDsn, field_validator, EmailStr
from pydantic_settings import BaseSettings
from cryptography.fernet import Fernet


class Settings(BaseSettings):
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    # 60 minutes * 24 hours * 8 days = 8 days
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8
    # BACKEND_CORS_ORIGINS is a JSON-formatted list of origins
    # e.g: ["http://localhost", "http://localhost:4200", "http://localhost:3000"]
    BACKEND_CORS_ORIGINS: List[AnyHttpUrl] = []

    @field_validator("BACKEND_CORS_ORIGINS", mode="before")
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)

    PROJECT_NAME: str
    
    DATABASE_URL: str

    # SMTP配置
    SMTP_HOST: str
    SMTP_PORT: int = 587
    SMTP_USER: str
    SMTP_PASSWORD: str
    SMTP_FROM_EMAIL: EmailStr
    
    # 支付加密密钥，如果环境变量中没有，则生成一个新的
    PAYMENT_ENCRYPTION_KEY: str = os.environ.get("PAYMENT_ENCRYPTION_KEY", urlsafe_b64encode(os.urandom(32)).decode())


    class Config:
        case_sensitive = True
        env_file = ".env"


settings = Settings()