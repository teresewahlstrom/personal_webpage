from __future__ import annotations

import os
from pathlib import Path
from threading import Lock

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from langchain_core.chat_history import InMemoryChatMessageHistory
from langchain_core.messages import AIMessage, HumanMessage, SystemMessage
from langchain_openai import ChatOpenAI
from pydantic import BaseModel, Field

from backend.twin.retrieval.dummy_context import build_system_prompt


WORKSPACE_ROOT = Path(__file__).resolve().parents[2]
load_dotenv(WORKSPACE_ROOT / '.env')


class TwinChatRequest(BaseModel):
    session_id: str = Field(min_length=1, alias='sessionId')
    message: str = Field(min_length=1)
    retrieval_context: str | None = Field(default=None, alias='retrievalContext')

    model_config = {
        'populate_by_name': True,
    }


class TwinChatResponse(BaseModel):
    reply: str


app = FastAPI(title='Personal Website Twin Prototype API')
_model: ChatOpenAI | None = None
_session_histories: dict[str, InMemoryChatMessageHistory] = {}
_session_histories_lock = Lock()
_max_history_messages = max(2, int(os.getenv('TWIN_MAX_HISTORY_MESSAGES', '12')))
def _get_session_history(session_id: str) -> InMemoryChatMessageHistory:
    with _session_histories_lock:
        history = _session_histories.get(session_id)
        if history is None:
            history = InMemoryChatMessageHistory()
            _session_histories[session_id] = history
        return history


def _remember_turn(session_id: str, user_message: str, twin_reply: str) -> None:
    with _session_histories_lock:
        history = _session_histories.get(session_id)
        if history is None:
            history = InMemoryChatMessageHistory()
            _session_histories[session_id] = history
        history.add_messages(
            [
                HumanMessage(content=user_message),
                AIMessage(content=twin_reply),
            ]
        )
        if len(history.messages) > _max_history_messages:
            history.messages = history.messages[-_max_history_messages:]


def _get_model() -> ChatOpenAI:
    global _model
    if _model is not None:
        return _model

    api_key = os.getenv('OPENAI_API_KEY')
    if not api_key:
        raise RuntimeError('OPENAI_API_KEY is missing from the workspace .env file.')

    model_name = os.getenv('OPENAI_MODEL', 'gpt-4')
    _model = ChatOpenAI(api_key=api_key, model=model_name, temperature=0.35)
    return _model


@app.get('/health')
def health() -> dict[str, str | bool]:
    return {
        'ok': True,
        'model': os.getenv('OPENAI_MODEL', 'gpt-4'),
    }


@app.post('/twin/chat', response_model=TwinChatResponse)
def twin_chat(request: TwinChatRequest) -> TwinChatResponse:
    message = request.message.strip()
    if message == '':
        raise HTTPException(status_code=400, detail='message is required')

    session_history = _get_session_history(request.session_id)
    prior_messages = list(session_history.messages)

    try:
        response = _get_model().invoke(
            [
                SystemMessage(
                    content=build_system_prompt(request.retrieval_context)
                ),
                *prior_messages,
                HumanMessage(content=message),
            ]
        )
    except Exception as error:
        raise HTTPException(status_code=502, detail=f'python twin failed: {error}') from error

    reply = getattr(response, 'content', '')
    if not isinstance(reply, str) or reply.strip() == '':
        raise HTTPException(status_code=502, detail='python twin returned an empty reply')

    reply = reply.strip()
    _remember_turn(request.session_id, message, reply)

    return TwinChatResponse(reply=reply)