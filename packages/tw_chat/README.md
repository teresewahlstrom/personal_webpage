# tw_chat

Internal chat package extracted from the `personal_webpage` app.

It owns the Flutter chat UI, message rendering, selection and copy behavior, and conversation-side state handling.

The package remains Twin-specific for this app, but it does not own network transport or backend protocol details.

It does not own retrieval orchestration (RAG graph), LLM runtime behavior, backend policy, or HTTP transport. Those responsibilities live in the app and backend services.

## Controller and Client Notes

- `TwinConversationController` treats injected `TwinReplyClient` as borrowed by default.
- Pass `ownsReplyClient: true` only when the controller should dispose the client.
- `TwinReplyClient` is an app-provided transport seam. The app decides whether replies come from HTTP, local mocks, or another runtime.
