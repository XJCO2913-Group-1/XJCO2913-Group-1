import json
from typing import AsyncGenerator, List
from fastapi import APIRouter, Depends, HTTPException
import httpx

from app.core.config import settings
from app.api.deps import get_current_user, get_db
from app.models.llm import Conversation, Message
from app.schemas.llm import (
    LLMRequest,
    ConversationCreate,
    ConversationResponse,
    MessageCreate,
    MessageResponse,
)
from sse_starlette.sse import EventSourceResponse


router = APIRouter()


async def call_llm_api(
    query: str, history_chat: List[str]
) -> AsyncGenerator[str, None]:
    """
    调用LLM API并返回流式响应
    """
    request_data = {
        "uid": "123",
        "cid": "123",
        "status": 0,
        "query": query,
        "history_chat": history_chat,
    }

    url = str(settings.LLM_URL)

    async with httpx.AsyncClient() as client:
        async with client.stream(
            "POST", url, json=request_data, timeout=60.0
        ) as response:
            if response.status_code != 200:
                error_msg = json.dumps(
                    {
                        "status": -1,
                        "error": f"LLM API请求失败: {response.status_code}",
                        "answer": "",
                    }
                )
                yield f"data:{error_msg}\n\n"
                return

            async for chunk in response.aiter_text():
                if chunk.startswith("data:"):
                    yield chunk
                else:
                    # 确保格式正确
                    yield f"data:{chunk}\n\n"


async def format_history_for_llm(conversation_messages) -> List[str]:
    """
    将数据库中的对话记录格式化为LLM API所需的格式
    """
    history_chat = []
    for message in conversation_messages:
        if message.is_user:
            history_chat.append(message.content)  # 用户问题
        else:
            history_chat.append(message.content)  # AI回答
    return history_chat


async def process_llm_request(request: LLMRequest) -> EventSourceResponse:
    """
    处理LLM请求并返回SSE响应
    """
    return EventSourceResponse(
        call_llm_api(request.query, request.history_chat),
        media_type="text/event-stream",
    )


# 创建新对话
@router.post("/api/conversations", response_model=ConversationResponse)
async def create_conversation(
    conversation: ConversationCreate,
    current_user=Depends(get_current_user),
    db=Depends(get_db),
):
    """
    创建新的对话
    """
    db_conversation = Conversation(title=conversation.title, user_id=current_user.id)
    db.add(db_conversation)
    db.commit()
    db.refresh(db_conversation)
    return db_conversation


# 获取用户的所有对话
@router.get("/api/conversations", response_model=List[ConversationResponse])
async def get_conversations(current_user=Depends(get_current_user), db=Depends(get_db)):
    """
    获取当前用户的所有对话列表
    """
    conversations = (
        db.query(Conversation).filter(Conversation.user_id == current_user.id).all()
    )
    return conversations


# 获取特定对话
@router.get("/api/conversations/{conversation_id}", response_model=ConversationResponse)
async def get_conversation(
    conversation_id: int,
    current_user=Depends(get_current_user),
    db=Depends(get_db),
):
    """
    获取指定ID的对话信息
    """
    conversation = (
        db.query(Conversation)
        .filter(
            Conversation.id == conversation_id, Conversation.user_id == current_user.id
        )
        .first()
    )
    if not conversation:
        raise HTTPException(status_code=404, detail="对话不存在")
    return conversation


# 获取对话的所有消息
@router.get(
    "/api/conversations/{conversation_id}/messages",
    response_model=List[MessageResponse],
)
async def get_messages(
    conversation_id: int,
    current_user=Depends(get_current_user),
    db=Depends(get_db),
):
    """
    获取指定对话的所有消息
    """
    # 验证对话存在且属于当前用户
    conversation = (
        db.query(Conversation)
        .filter(
            Conversation.id == conversation_id, Conversation.user_id == current_user.id
        )
        .first()
    )
    if not conversation:
        raise HTTPException(status_code=404, detail="对话不存在")

    messages = (
        db.query(Message)
        .filter(Message.conversation_id == conversation_id)
        .order_by(Message.created_at)
        .all()
    )
    return messages


# 创建新消息并获取LLM回复
@router.post("/api/conversations/{conversation_id}/messages")
async def create_message(
    conversation_id: int,
    message: MessageCreate,
    current_user=Depends(get_current_user),
    db=Depends(get_db),
):
    """
    创建新消息并获取LLM的回复
    """
    # 验证对话存在且属于当前用户
    conversation = (
        db.query(Conversation)
        .filter(
            Conversation.id == conversation_id, Conversation.user_id == current_user.id
        )
        .first()
    )
    if not conversation:
        raise HTTPException(status_code=404, detail="对话不存在")

    # 保存用户消息
    db_message = Message(
        conversation_id=conversation_id, content=message.content, is_user=True
    )
    db.add(db_message)
    db.commit()

    # 检查是否是第一条消息，如果是则更新对话标题
    message_count = (
        db.query(Message).filter(Message.conversation_id == conversation_id).count()
    )
    if message_count == 1:
        # 截取用户消息的前30个字符作为标题，如果超过30个字符则添加...
        new_title = message.content[:30] + ("..." if len(message.content) > 30 else "")
        conversation.title = new_title

    # 更新对话的更新时间
    conversation.updated_at = (
        db.query(Message)
        .filter(Message.conversation_id == conversation_id)
        .order_by(Message.created_at.desc())
        .first()
        .created_at
    )
    db.commit()

    # 获取历史消息
    messages = (
        db.query(Message)
        .filter(Message.conversation_id == conversation_id)
        .order_by(Message.created_at)
        .all()
    )
    history_chat = await format_history_for_llm(messages)

    # 创建LLM请求
    llm_request = LLMRequest(query=message.content, history_chat=history_chat)

    # 返回流式响应
    return await process_llm_request(llm_request)
