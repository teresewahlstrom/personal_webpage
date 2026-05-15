# White Keyboard Area Fix: Research and Implementation Log

## Problem Statement

When a user locks a phone while the chat composer keyboard is open, then unlocks later, a persistent white keyboard-height area remains on screen. The gap clears only after another interaction.

Observed trigger:

1. Open the chat composer.
2. Tap the input so the software keyboard opens.
3. Lock the phone while the keyboard is still open.
4. Wait briefly.
5. Unlock the phone.
6. The physical keyboard is gone, but a white gap remains where the keyboard was.

The issue has reproduced in Flutter Web on mobile browsers, including iOS Safari and Android Chrome.

## Current Working Theory

This is not just a chat layout bug. It is a lifecycle/focus/viewport desynchronization bug across three layers:

- Flutter focus and `TextInputConnection` state.
- Flutter Web engine metrics (`View.viewInsets`, `MediaQuery.viewInsets`).
- Browser viewport state (`window.innerHeight`, `visualViewport`, and the hidden DOM input used by Flutter Web).

The white area appears when the app resumes with at least one layer still believing a text input or keyboard is active after the real keyboard has disappeared.

Confirmed fix direction after real-device testing:

- The durable fix is to clear mobile/web text-input state at the text-field primitive layer.
- App-level keyboard layout observers should measure keyboard height only; they should not own text-input focus recovery.

## External References

- Flutter issue #131840: iOS reports white keyboard space after background/foreground with a focused `TextField`.
  https://github.com/flutter/flutter/issues/131840
- Flutter issue #124205: Flutter Web text input/viewport offset behavior when keyboard opens.
  https://github.com/flutter/flutter/issues/124205
- Flutter issue #135800: iOS Safari keyboard/layout instability for Flutter Web.
  https://github.com/flutter/flutter/issues/135800
- MDN viewport meta tag: `interactive-widget` can change whether the keyboard resizes visual viewport, layout viewport, or neither.
  https://developer.mozilla.org/en-US/docs/Web/HTML/Viewport_meta_tag
- MDN VirtualKeyboard API: browsers can opt out of automatic viewport resizing, but support is limited and not a reliable iOS Safari solution.
  https://developer.mozilla.org/en-US/docs/Web/API/VirtualKeyboard_API

## What We Tried

### 1. Global KeyboardHeight Observer

Files:

- [lib/services/keyboard_height.dart](../lib/services/keyboard_height.dart)
- [lib/services/keyboard_viewport_bridge.dart](../lib/services/keyboard_viewport_bridge.dart)
- [lib/services/keyboard_viewport_bridge_stub.dart](../lib/services/keyboard_viewport_bridge_stub.dart)
- [lib/services/keyboard_viewport_bridge_web.dart](../lib/services/keyboard_viewport_bridge_web.dart)

The observer was added at the app root in [lib/main.dart](../lib/main.dart). It combined Flutter's inset with a web `visualViewport` estimate.

Initial strategy:

- Compute Flutter inset from `View.viewInsets.bottom`.
- Compute web inset from `window.innerHeight - visualViewport.height - visualViewport.offsetTop`.
- Publish `max(flutterInset, webInset)`.
- Recompute after lifecycle changes and metric changes.

Result:

- Did not fix the lock/unlock bug.
- Likely weakness: `max(...)` preserves stale positive values. If either Flutter or the browser remains stuck at keyboard height, the app continues to reserve keyboard space.

### 2. Consumer Migration Away From Raw viewInsets

Files:

- [lib/widgets/app_modal.dart](../lib/widgets/app_modal.dart)
- [lib/widgets/shell/_chat_overlay.dart](../lib/widgets/shell/_chat_overlay.dart)
- [packages/tw_chat/lib/src/widgets/chat_dock.dart](../packages/tw_chat/lib/src/widgets/chat_dock.dart)
- [packages/tw_chat/lib/src/config/layout.dart](../packages/tw_chat/lib/src/config/layout.dart)
- [packages/tw_chat/test/layout_test.dart](../packages/tw_chat/test/layout_test.dart)

The app modal and chat dock stopped reading raw `MediaQuery.viewInsets.bottom` and instead consumed `KeyboardHeight`.

Result:

- Cleaner data flow.
- Did not fix the persisted white area.
- This suggests the bad state can exist below normal widget layout, either in Flutter Web's text input connection or browser viewport state.

### 3. Resume Suppression Window

Attempt:

- On resume, unfocus Flutter focus.
- Temporarily suppress positive keyboard insets for about 1200 ms.
- Add more delayed recompute passes.

Result:

- Deployed and verified by UI test.
- White area persisted.

Likely weakness:

- A timed suppression window is probabilistic. If stale browser/engine state persists longer than the window, the positive inset comes back.
- It also adds complexity without telling us which layer is wrong.

### 4. Host Page Viewport Script

File:

- [web/index.html](../web/index.html)

Attempt:

- Add `interactive-widget=resizes-content`.
- Add a CSS `--app-height` driven by `visualViewport.height`.
- Force `html`, `body`, `#app`, `flt-glass-pane`, and `flutter-view` to that height.
- Blur focused DOM inputs on resume-like browser events.
- Repeat viewport recovery at several delays.

Result:

- Deployed and verified by UI test.
- White area persisted.

Audit conclusion:

- This likely made the system harder to reason about. The browser, host page, and Flutter layout were all trying to own keyboard resizing.
- `interactive-widget=resizes-content` is Android-oriented and not a reliable iOS Safari escape hatch.
- Driving the Flutter host height from `visualViewport.height` can preserve a stale shrunken viewport if `visualViewport` itself is the lying metric.

This experiment has been removed.

## Full Audit Findings

### Finding 1: iOS SuperTextField Did Not Clear IME On Background

Android implementation:

- [packages/tw_primitives/lib/src/text_field/super_textfield/android/android_textfield.dart](../packages/tw_primitives/lib/src/text_field/super_textfield/android/android_textfield.dart)
- Registers `WidgetsBindingObserver`.
- On `inactive`, `hidden`, or `paused`, it unfocuses and detaches from IME.

iOS implementation before the latest fix:

- [packages/tw_primitives/lib/src/text_field/super_textfield/ios/ios_textfield.dart](../packages/tw_primitives/lib/src/text_field/super_textfield/ios/ios_textfield.dart)
- Registered `WidgetsBindingObserver`.
- Reacted to metrics changes.
- Did not implement lifecycle cleanup.

Why this matters:

- The failing scenario is specifically background/foreground with an active text input.
- Flutter issue #131840 is also about white keyboard space after background/foreground with a focused text field.
- If the iOS text field keeps its `TextInputConnection` alive during lock/background, Flutter Web can keep the hidden DOM text input or engine keyboard metrics in a stale state.

Fix:

- iOS now mirrors Android and calls `_clearFocusAndImeForBackgroundTransition()` on `inactive`, `hidden`, and `paused`.
- Shared lifecycle decisions now live in [packages/tw_primitives/lib/src/text_field/super_textfield/infrastructure/text_input_lifecycle.dart](../packages/tw_primitives/lib/src/text_field/super_textfield/infrastructure/text_input_lifecycle.dart).
- Web DOM editable focus cleanup now lives in `tw_primitives` under [packages/tw_primitives/lib/src/text_field/infrastructure/platforms/web/](../packages/tw_primitives/lib/src/text_field/infrastructure/platforms/web/).

### Finding 2: App-Level DOM Focus Cleanup Was The Wrong Long-Term Owner

Previous behavior:

- Positive keyboard height could be republished after resume even when the text input was unfocused, as long as Flutter or the browser still reported stale positive metrics.
- `KeyboardHeightObserver` briefly took responsibility for clearing Flutter focus and browser DOM editable focus.

Final cleanup:

- The DOM focus cleanup moved out of the app service and into `tw_primitives`.
- `KeyboardHeightObserver` is back to measuring keyboard height for layout.
- The app web viewport bridge no longer knows about DOM focus.

Why this is simpler:

- Text fields own text-input lifecycle.
- App layout owns app layout.
- This removes cross-layer coupling between `KeyboardHeight` and Flutter Web's hidden editable DOM element.

### Finding 3: The Host Page Should Not Own Keyboard Layout

Latest direction:

- [web/index.html](../web/index.html) is back to a simple fixed full-height Flutter host.
- Keep `viewport-fit=cover`.
- Remove `interactive-widget=resizes-content`.
- Remove the `--app-height` script.

Reason:

- The app already has Flutter-side keyboard-aware layout.
- Adding host-page visual viewport sizing creates a second layout owner.
- The white bug is easier to isolate if the browser shell is boring and Flutter/input lifecycle owns the recovery.

## Confirmed Fix

The bug was fixed by moving cleanup to the text-input lifecycle:

1. Add iOS text field lifecycle cleanup in `SuperIOSTextField`.
2. Keep Android and iOS lifecycle behavior aligned through `text_input_lifecycle.dart`.
3. Add primitive-level web DOM editable blur on background transitions.
4. Simplify `web/index.html` back to a full-height host only.
5. Remove app-level DOM focus cleanup from `KeyboardHeightObserver`.

This was validated in the lock/unlock scenario that had been reproducing the persistent white keyboard area.

## Next Things To Try If This Still Fails

### Option A: Replace SuperTextField In The Chat Composer Temporarily

Use Flutter's built-in `TextField` for the chat composer behind a small switch.

Purpose:

- If the bug disappears, the problem is in our internal `SuperTextField` IME lifecycle.
- If the bug remains, the problem is likely Flutter Web/browser viewport behavior outside `SuperTextField`.

This is the most valuable isolation test.

### Option B: Add A Temporary On-Screen Keyboard Debug Panel

Show these values in a small debug-only overlay:

- `KeyboardHeight.of(context)`
- Flutter `View.viewInsets.bottom`
- Web `visualViewport.height`
- Web `visualViewport.offsetTop`
- `window.innerHeight`
- Whether the DOM active element is editable
- Flutter `FocusManager.instance.primaryFocus?.debugLabel`

Purpose:

- Real-device lock/unlock is hard to inspect remotely.
- This would tell us whether the stuck white area is caused by stale app layout, stale Flutter metrics, stale visual viewport, or a focused hidden DOM input.

### Option C: Make Chat Composer Close On App Background At The Package Boundary

Add an explicit callback or lifecycle observer in `tw_chat` that clears composer focus and selection on app background.

Purpose:

- Defense in depth if platform text field cleanup is not enough.
- Lower-level than app overlay code, higher-level than primitive IME internals.

### Option D: Remove KeyboardHeight From Floating Dock Positioning

Try letting the browser/Flutter viewport resize drive layout naturally, with no `bottom: keyboardHeight`.

Purpose:

- Tests whether our manual chat movement is double-counting keyboard space.
- This should be treated as an experiment because it may regress keyboard avoidance while typing.

## Current Recommendation

Keep the responsibility split:

- `tw_primitives` text fields own focus, IME, and web DOM editable cleanup.
- App-level `KeyboardHeight` owns keyboard-height measurement for layout.
- `tw_chat` owns chat-specific placement above a legitimate keyboard.

If the issue ever returns, use Option A as the next isolation test: temporarily replace the composer `SuperTextField` with Flutter's standard `TextField`.

---

Last updated: May 15, 2026
