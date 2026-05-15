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

Latest change:

- iOS now mirrors Android and calls `_clearFocusAndImeForBackgroundTransition()` on `inactive`, `hidden`, and `paused`.

### Finding 2: KeyboardHeight Should Not Publish Keyboard Space Without Text Input Focus

Previous behavior:

- Positive keyboard height could be republished after resume even when the text input was unfocused, as long as Flutter or the browser still reported stale positive metrics.

Latest change:

- The web viewport bridge now reports whether the actual browser editable element is focused.
- `KeyboardHeight` publishes `0` unless a real web text input/editing element is focused.
- On background transitions, `KeyboardHeightObserver` unfocuses Flutter focus and also asks the web bridge to blur the active editable DOM element.

Why this is simpler:

- It removes the timed stale-inset suppression window.
- It makes stale viewport metrics advisory only; they cannot create keyboard space unless text input focus is still real.

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

## Current Candidate Fix

The latest code changes are:

1. Add iOS text field lifecycle cleanup in `SuperIOSTextField`.
2. Simplify `web/index.html` back to full-height host only.
3. Change `KeyboardHeight` to publish keyboard height only while a real text input is focused.
4. Add web bridge helpers for detecting and clearing focused editable DOM elements.

This is a root-cause-oriented attempt, not another delayed resize patch.

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

Test the latest candidate fix first. If the white area still persists, do Option A next: temporarily replace the composer `SuperTextField` with Flutter's standard `TextField`. That will split the problem cleanly between internal text field lifecycle and Flutter Web/browser behavior.

---

Last updated: May 15, 2026
