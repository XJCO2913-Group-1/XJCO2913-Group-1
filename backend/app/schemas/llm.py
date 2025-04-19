from datetime import datetime
from typing import List
from pydantic import BaseModel, Field


class LLMRequest(BaseModel):
    query: str
    history_chat: List[str] = Field(default_factory=list)


class LLMResponse(BaseModel):
    status: int
    uid: str
    cid: str
    answer: str


class ConversationBase(BaseModel):
    title: str = "新对话"


class ConversationCreate(ConversationBase):
    pass


class ConversationResponse(ConversationBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True


# 消息相关模型
class MessageBase(BaseModel):
    content: str
    is_user: bool = True


class MessageCreate(MessageBase):
    conversation_id: int


class MessageResponse(MessageBase):
    id: int
    conversation_id: int
    created_at: datetime

    class Config:
        orm_mode = True
