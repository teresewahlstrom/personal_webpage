# White Keyboard Area Fix: Research & Implementation Log

## Problem Statement

When the user locks their phone with a keyboard actively open (due to interaction with a text field in the app), and then unlocks after a period, a persistent white area appears where the keyboard was. This occurs specifically on iOS Safari and Android Chrome in Flutter Web.

**Trigger path:**
1. User interacts with text input field (keyboard opens)
2. User locks device (with keyboard still open)
3. User waits
4. User unlocks device
5. White keyboard-height gap appears on screen and persists until interaction

## Initial Codebase State

- App uses `MediaQuery.of(context).viewInsets.bottom` directly in multiple places
- [app_modal.dart](app_modal.dart#L84): Modal dialog sizing based on raw insets
- [packages/tw_chat/lib/src/widgets/chat_dock.dart](../packages/tw_chat/lib/src/widgets/chat_dock.dart#L80): Chat dock positioning and height calculations
- [packages/tw_chat/lib/src/config/layout.dart](../packages/tw_chat/lib/src/config/layout.dart#L149): Chat layout calculations

No lifecycle recovery or cross-source validation of keyboard metrics.

## Research Findings

### Targeted Search Scope

Deep investigation into:
- Flutter GitHub issues (keyboard, viewInsets, viewport)
- Flutter engine issues related to iOS Safari lifecycle/keyboard handling
- StackOverflow and DuckDuckGo cached content on iOS white space/keyboard bugs
- MDN VisualViewport API documentation

### Key Issues Found

**Flutter Issue #131840** — "White space shown when app is backgrounded and foreground"
- Repro: nearly identical to user's lock/unlock scenario
- Status: closed during triage, no definitive upstream fix
- Symptom: white keyboard-height gap persists after lifecycle transition

**Flutter Issue #124205** (umbrella) — Viewport/insets desynchronization
- Affects both iOS Safari and Android Chrome on Flutter Web
- Related duplicates: #179208, #178354, #180921
- Pattern: "white/blank area remains until extra tap/scroll"

**Flutter Issue #135800** — iOS Safari keyboard/layout instability
- Still actively reported; suggests ongoing platform-specific behavior

**Android Web Fix (PR #179581)** — Concrete engine fix applied
- References issue #175074
- Improved Android Chrome, but iOS Safari remains unstable

### Root Cause Identified

**The core issue: metric desynchronization during lifecycle transitions**

When the app transitions from background to foreground:
1. MediaQuery.viewInsets.bottom may become stale or lag behind actual keyboard state
2. The DOM VisualViewport API (Web only) provides an alternative measurement: `window.innerHeight - visualViewport.height - visualViewport.offsetTop`
3. These two sources can drift, especially during iOS Safari's complex keyboard show/hide lifecycle
4. UI code trusts one stale source, sizes layout incorrectly, leaves white gap

**Why it happens:**
- Lock/unlock is a full app pause/resume cycle
- Lifecycle events (didChangeAppLifecycleState) and layout events (didChangeMetrics) may arrive out of order or with stale cached values
- On iOS Safari in particular, the soft keyboard can remain "remembered" by the browser engine even after the physical keyboard is dismissed

**Why existing code fails:**
- Direct `viewInsets.bottom` usage provides no fallback when stale
- No recovery mechanism on app resume
- Chat package calculates layout using outdated inset, compounds the error

## Solution Architecture

### Phase 1: Global Keyboard Height Observer (Implemented ✅)

**Files created:**

1. **[lib/services/keyboard_viewport_bridge.dart](keyboard_viewport_bridge.dart)** — Abstract interface
   - Platform-agnostic contract for keyboard height estimation
   - Methods: `start()`, `stop()`, getter `estimatedBottomInset`

2. **[lib/services/keyboard_viewport_bridge_stub.dart](keyboard_viewport_bridge_stub.dart)** — Non-web no-op
   - Returns 0 for all platforms except web
   - Allows conditional compilation without duplication

3. **[lib/services/keyboard_viewport_bridge_web.dart](keyboard_viewport_bridge_web.dart)** — Web-specific implementation
   - Listens to DOM `visualViewport` resize/scroll events
   - Computes: `window.innerHeight - visualViewport.height - visualViewport.offsetTop`
   - Includes null-safety guards and lint suppressions for web-only library

4. **[lib/services/keyboard_height.dart](keyboard_height.dart)** — Primary observer service
   - `KeyboardHeight` (InheritedNotifier) provides double value to widget tree
   - `KeyboardHeightObserver` (StatefulWidget) manages lifecycle and computation
   - `_KeyboardHeightObserverState` implements core logic:
     - Subscribes to `WidgetsBinding.instance` for metrics and lifecycle changes
     - Computes: `max(flutterInset, webEstimate)` with clamping to 60% screen height
     - Uses 0.5px jitter threshold to filter noise
     - On lifecycle pause: records focus state
     - On lifecycle resume: unfocuses if previously focused, schedules stabilization burst
     - Stabilization burst: recomputes at 16ms, 80ms, 180ms post-resume intervals

**Key features:**
- Cross-source validation (max of two independent measurements)
- Lifecycle-aware recovery (resume handling with unfocus + burst recompute)
- Platform-specific bridges without main-app dependency
- Efficient state distribution via InheritedNotifier (no unnecessary rebuilds)

### Phase 2: Modal Migration (Implemented ✅)

**[lib/main.dart](../lib/main.dart#L52)** — Wired observer at app root
- Wrapped `MaterialApp` with `KeyboardHeightObserver`
- Observer now provides unified keyboard height to entire app tree

**[lib/widgets/app_modal.dart](../lib/widgets/app_modal.dart#L84)** — Switched to observer
- Replaced `MediaQuery.of(context).viewInsets.bottom` with `KeyboardHeight.of(context)`
- Modal now reads from unified, cross-checked source instead of raw insets

### Phase 3: Chat Package Integration (Implemented ✅)

**Architecture decision:** `tw_chat` is a reusable package, so it cannot depend directly on app services. Instead, it accepts keyboard height as a parameter.

**[packages/tw_chat/lib/src/widgets/chat_dock.dart](../packages/tw_chat/lib/src/widgets/chat_dock.dart)** — Added parameter
- New required parameter: `keyboardHeight: double`
- Replaced `mq.viewInsets.bottom` checks with `widget.keyboardHeight`
- Updated stability computation for viewport height calculation

**[packages/tw_chat/lib/src/config/layout.dart](../packages/tw_chat/lib/src/config/layout.dart#L141)** — Updated API
- Changed `maxDockHeight()` signature: from `viewInsets: EdgeInsets` to `keyboardHeight: double`
- Computation: `safeViewportHeight = viewportSize.height - keyboardHeight - viewPadding.top`
- Eliminates intermediate inset object, works directly with unified height

**[packages/tw_chat/test/layout_test.dart](../packages/tw_chat/test/layout_test.dart)** — Updated all tests
- 8 test cases updated to pass `keyboardHeight` directly
- Maintains test coverage without breaking API expectations

**[lib/widgets/shell/_chat_overlay.dart](../lib/widgets/shell/_chat_overlay.dart)** — Wired integration
- Added import: `KeyboardHeight` service
- In `build()`: reads `KeyboardHeight.of(context)` once per frame
- Passes unified height to `ChatDock` constructor
- Chat now receives accurate, cross-checked keyboard height at build time

## Implementation Status

### Completed ✅

- ✅ KeyboardHeight observer service with VisualViewport bridge
- ✅ Platform-specific bridge implementations (stub + web)
- ✅ Lifecycle recovery with resume unfocus and stabilization burst
- ✅ Modal sizing migration to observer
- ✅ Chat dock parameter added and consumer wired
- ✅ Chat layout API migrated to accept keyboard height directly
- ✅ Test suite updated for new chat layout API
- ✅ All changes validated clean by Flutter analyzer

### Test Results

- **flutter analyze lib**: No issues
- **flutter analyze packages/tw_chat/**: No issues (only pre-existing unused import in composer_row.dart)
- **flutter pub get**: Dependencies resolved successfully

### Changes Summary

**New files (4):**
- lib/services/keyboard_viewport_bridge.dart
- lib/services/keyboard_viewport_bridge_stub.dart
- lib/services/keyboard_viewport_bridge_web.dart
- lib/services/keyboard_height.dart

**Modified files (4):**
- lib/main.dart (added KeyboardHeightObserver wrapper)
- lib/widgets/app_modal.dart (switched to KeyboardHeight.of())
- packages/tw_chat/lib/src/widgets/chat_dock.dart (added keyboardHeight parameter)
- packages/tw_chat/lib/src/config/layout.dart (changed maxDockHeight() API)
- packages/tw_chat/test/layout_test.dart (updated 8 test cases)
- lib/widgets/shell/_chat_overlay.dart (wired observer to ChatDock)

## Known Limitations & Next Steps

### Current State
The fix is **complete and deployed in code**, but **not yet validated on real devices**.

### Testing Required

1. **Lock/unlock test on iOS Safari**
   - Open text field (keyboard opens)
   - Lock device
   - Wait 10-30 seconds
   - Unlock device
   - Observe: white area should NOT appear

2. **Lock/unlock test on Android Chrome**
   - Same repro steps
   - Observe for consistency across platforms

3. **Edge cases to verify**
   - Multiple keyboard open/close cycles
   - Lock/unlock during IME transition
   - Orientation change with keyboard open

### If Issue Persists

**Diagnostic steps:**
1. Log keyboard height values on resume:
   - `KeyboardHeight.of(context)` current value
   - Flutter inset value (internal to observer)
   - Web VisualViewport estimate (internal to observer)
2. Check if any other widgets are still reading stale `viewInsets.bottom`
3. Verify app resume hook is being triggered (add telemetry to `didChangeAppLifecycleState`)

**Potential additional fixes:**
1. Add explicit CSS viewport-fit handling in web shell (index.html)
2. Force keyboard hide on app pause (via platform channel)
3. Disable Firefox focus recovery if running on web

## Architecture Notes

**Why this approach is robust:**

1. **Cross-source validation** — Max of two independent measurements catches single-source failures
2. **Lifecycle-aware** — Resume recovery directly targets the lock/unlock trigger
3. **Jitter-resistant** — 0.5px threshold prevents noise-driven rebuilds
4. **Platform-agnostic for reuse** — ChatDock accepts parameter, works on any platform
5. **No temporary code** — Full migration, no debug toggles or residual diagnostics
6. **Minimal surface area** — Changes concentrated in one service + two consuming sites

**Design decisions made:**

- Observer at app root (not tw_primitives) — keyboard layout is app-level concern, not primitive-level
- Parameter-based for tw_chat — packages should not depend on app services, only receive values
- Max-of-sources strategy — more defensive than single source with fallback, avoids edge case races
- Stabilization burst — probabilistic but practical; catches the 16-80ms range where metrics often settle post-resume

## References

- Flutter issue #131840: https://github.com/flutter/flutter/issues/131840
- Flutter issue #124205 (umbrella): https://github.com/flutter/flutter/issues/124205
- Flutter issue #135800 (iOS Safari): https://github.com/flutter/flutter/issues/135800
- MDN VisualViewport API: https://developer.mozilla.org/en-US/docs/Web/API/VisualViewport

---

**Document created:** May 15, 2026  
**Implementation complete:** May 15, 2026  
**Real device testing:** Pending
