# tw_chat

Internal Flutter chat package for the `personal_webpage` app.

`tw_chat` owns the floating chat UI, transcript rendering, chat selection/copy behavior, composer wiring, keyboard routing, and conversation-side state. It remains Twin-specific and app-internal.

It does not own retrieval orchestration, LLM behavior, backend policy, HTTP transport, or app-level viewport/browser policy.

## Public Entry Points

- `chat.dart`
  - `ChatLauncherStyle`
  - `ChatOverlay`
  - `ChatKeyboardScrollTargetController`
  - `ChatSkin` / `ChatSkinMode`

## Main Responsibilities

- Floating chat dock with minimized and expanded states.
- Responsive dock sizing based on viewport, safe area, and keyboard height supplied by the app.
- Message transcript rendering with bot/user bubbles.
- Markdown-ish message markup via `tw_primitives/markdown.dart`.
- Collapsible long bubbles with full-message copy behavior.
- Composer row using `TwReadyTextField`.
- Keyboard handoff between page scrolling, chat scrolling, and composer text entry.
- Web copy interception for chat selections.
- Web secondary-click selection guard so right-clicking selected chat text does not mutate selection.

## Conversation and Transport Boundary

`ConversationController` owns local conversation state and pending reply lifecycle. It accepts an injected `ReplyClient`.

- Injected `ReplyClient`s are borrowed by default.
- Pass `ownsReplyClient: true` only when the controller should dispose the client.
- The app decides whether replies come from HTTP, local mocks, or another runtime.

## Selection and Copy Notes

Chat transcript selection is intentionally separate from page selection.

- Chat selection clears page selection when chat interaction is claimed.
- Page selection should not become active from right-clicking inside chat.
- Copying a selected truncated bubble should copy the intended full message body.
- A click/tap may clear chat selection; drag/scroll should not be treated as a clear-selection click.
- Web right-click uses a small DOM guard to let the browser context menu open while preventing Flutter `SelectionArea` from replacing the active selection.

## Truncated Bubble Notes

Collapsed bubbles render clipped visible content, but copy behavior still uses the full message when a truncated bubble is part of the selected range.

The truncation path has historically been sensitive to:

- selection geometry drifting from styled markup,
- hidden content contributing selectable handles,
- overflow from markdown layout,
- preserving full-copy semantics while clipping visible layout.

Keep these on the manual regression list when changing bubble layout.

## Keyboard and Focus Notes

The app tells `ChatDock` the current keyboard height. `tw_chat` uses that value only for dock placement and sizing.

Keyboard routing is package-local:

- arrow up/down scroll the chat when chat is the keyboard scroll target,
- typed characters can redirect focus into the composer,
- typed character redirect is disabled while chat text is selected,
- composer focus uses the `TwReadyTextField` / `tw_primitives` text input stack.

App-level browser viewport and zoom policy belongs outside `tw_chat`, currently around `PageScaffold` / `web/index.html`.

## Skins and Tokens

The package exposes light/dark `ChatSkin` modes. Visual constants are still fairly chat-specific. A future cleanup may map the package's many local tokens onto fewer shared `tw_primitives` or app design tokens.

## Current Manual Regression Checklist

- Select text across normal and truncated bubbles.
- Right-click selected chat text on desktop Chrome; selection should remain chat-owned.
- Copy selected normal and truncated bubbles.
- Drag/scroll the chat list while text is selected; selection should not disappear.
- Tap/click after selecting chat text; selection may clear.
- Focus an empty composer on mobile Chrome; caret/handle should be visible.
- Type into chat when chat has keyboard focus; text should land in the composer.
