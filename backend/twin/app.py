from __future__ import annotations

import os
import sys
from functools import lru_cache
from pathlib import Path
from threading import Lock
from typing import Any

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field


WORKSPACE_ROOT = Path(__file__).resolve().parents[2]
TWIN_BACKEND_ROOT = Path(__file__).resolve().parent
TWIN_REPO_ROOT = Path(
    os.getenv('TWIN_REPO_ROOT', str(TWIN_BACKEND_ROOT / 'repo'))
).resolve()
TWIN_REPO_SRC_ROOT = TWIN_REPO_ROOT / 'src'
if not (TWIN_REPO_SRC_ROOT / 'twin').exists():
    raise RuntimeError(
        'Missing twin runtime package at '
        f'{TWIN_REPO_SRC_ROOT / "twin"}. '
        'Expected bridge target under backend/twin/repo/src/twin.'
    )
if str(TWIN_REPO_SRC_ROOT) not in sys.path:
    sys.path.insert(0, str(TWIN_REPO_SRC_ROOT))

load_dotenv(WORKSPACE_ROOT / '.env')

from twin.models import DEFAULT_CHAT_MODEL, DEFAULT_EMBEDDING_MODEL  # noqa: E402
from twin.paths import PROJECT_ROOT, RAG_ARTIFACT_PATH, RAG_RELATIONS_PATH, TWIN_DATA_DIR  # noqa: E402
from twin.runtime import generate_chat_reply  # noqa: E402
from twin.runtime.prompting import build_system_prompt  # noqa: E402


def _env_int(name: str, default: int, minimum: int = 1) -> int:
    raw_value = os.getenv(name)
    if raw_value is None:
        return default
    try:
        return max(minimum, int(raw_value))
    except ValueError:
        return default


def _env_float(name: str, default: float) -> float:
    raw_value = os.getenv(name)
    if raw_value is None:
        return default
    try:
        return float(raw_value)
    except ValueError:
        return default


def _env_bool(name: str, default: bool) -> bool:
    raw_value = os.getenv(name)
    if raw_value is None:
        return default
    normalized = raw_value.strip().lower()
    if normalized in {'1', 'true', 'yes', 'on'}:
        return True
    if normalized in {'0', 'false', 'no', 'off'}:
        return False
    return default


class ChatRequest(BaseModel):
    session_id: str = Field(min_length=1, alias='sessionId')
    message: str = Field(min_length=1)
    retrieval_context: str | None = Field(default=None, alias='retrievalContext')

    model_config = {
        'populate_by_name': True,
    }


class ChatResponse(BaseModel):
    reply: str


app = FastAPI(title='Personal Website Twin API')
_session_histories: dict[str, list[dict[str, str]]] = {}
_session_histories_lock = Lock()
_max_history_messages = _env_int('TWIN_MAX_HISTORY_MESSAGES', 12, minimum=2)
_default_top_k = _env_int('TWIN_RETRIEVAL_TOP_K', 15, minimum=1)
_default_retrieval_profile = os.getenv('TWIN_RETRIEVAL_PROFILE', 'full').strip() or 'full'
_default_include_trace = _env_bool('TWIN_INCLUDE_TRACE', False)
_default_chat_model = os.getenv('TWIN_CHAT_MODEL', DEFAULT_CHAT_MODEL).strip() or DEFAULT_CHAT_MODEL
_default_embedding_model = (
    os.getenv('TWIN_EMBEDDING_MODEL', DEFAULT_EMBEDDING_MODEL).strip() or DEFAULT_EMBEDDING_MODEL
)
_default_temperature = _env_float('TWIN_CHAT_TEMPERATURE', 0.0)


@lru_cache(maxsize=1)
def _base_system_prompt() -> str:
    return build_system_prompt()


def _system_prompt_for_request(retrieval_context: str | None) -> str:
    base_prompt = _base_system_prompt().rstrip()
    if retrieval_context is None or retrieval_context.strip() == '':
        return f'{base_prompt}\n'
    return (
        f'{base_prompt}\n\n'
        '## Additional Runtime Context\n'
        f'{retrieval_context.strip()}\n'
    )


def _get_session_history(session_id: str) -> list[dict[str, str]]:
    with _session_histories_lock:
        history = _session_histories.get(session_id)
        if history is None:
            history = []
            _session_histories[session_id] = history
        return list(history)


def _remember_turn(session_id: str, user_message: str, twin_reply: str) -> None:
    with _session_histories_lock:
        history = _session_histories.get(session_id)
        if history is None:
            history = []
            _session_histories[session_id] = history
        history.extend(
            [
                {'role': 'user', 'content': user_message},
                {'role': 'assistant', 'content': twin_reply},
            ]
        )
        if len(history) > _max_history_messages:
            _session_histories[session_id] = history[-_max_history_messages:]


@app.get('/health')
def health() -> dict[str, str | bool]:
    return {
        'ok': True,
        'chatModel': _default_chat_model,
        'embeddingModel': _default_embedding_model,
        'retrievalProfile': _default_retrieval_profile,
        'twinRepoRoot': str(TWIN_REPO_ROOT),
        'twinProjectRoot': str(PROJECT_ROOT),
        'subjectDataReady': TWIN_DATA_DIR.exists(),
        'ragArtifactReady': RAG_ARTIFACT_PATH.exists(),
        'ragRelationsReady': RAG_RELATIONS_PATH.exists(),
    }


@app.post('/twin/chat', response_model=ChatResponse)
def twin_chat(request: ChatRequest) -> ChatResponse:
    message = request.message.strip()
    if message == '':
        raise HTTPException(status_code=400, detail='message is required')

    prior_history = _get_session_history(request.session_id)

    try:
        result: dict[str, Any] = generate_chat_reply(
            message=message,
            history=prior_history,
            top_k=_default_top_k,
            embedding_model=_default_embedding_model,
            retrieval_profile=_default_retrieval_profile,
            include_trace=_default_include_trace,
            system_prompt=_system_prompt_for_request(request.retrieval_context),
            chat_model=_default_chat_model,
            temperature=_default_temperature,
        )
    except Exception as error:
        raise HTTPException(status_code=502, detail=f'python twin failed: {error}') from error

    reply = str(result.get('answer') or '').strip()
    if reply == '':
        raise HTTPException(status_code=502, detail='python twin returned an empty reply')

    _remember_turn(request.session_id, message, reply)
    return ChatResponse(reply=reply)
