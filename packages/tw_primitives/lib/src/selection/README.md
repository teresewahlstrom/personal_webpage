# Selection Fork (`selectable_region_fork.dart`)

This directory contains a custom fork of Flutter's internal `SelectableRegion` implementation, allowing us to solve several critical usability issues and bugs present in the upstream SDK's text selection system on mobile and desktop web targets.

## Upstream Flutter Bugs Solved by This Fork

1. **Bottom-to-Top Drag Highlights Bug**
   - *Issue:* In vanilla Flutter, dragging the selection cursor upwards (bottom-to-top) fails to render selection highlights. The internal loop assumes a left-to-right/top-to-bottom layout hierarchy (`start <= end`), causing increments to skip execution entirely when dragging backward.
   - *Fix:* Bounded the start and end indices using `min()` and `max()` in `getSelectionRects` so selection highlights paint correctly regardless of drag direction.

2. **Offscreen Handles & Toolbar Floating Bug**
   - *Issue:* If a user selects text in a scrollable area and scrolls the text out of view, Flutter's handles and contextual edit menu stay visible, floating awkwardly over other page elements.
   - *Fix:* Tied selection overlay handle and toolbar visibility to the viewport's bounding box using `_startHandleVisibleInViewport`, `_endHandleVisibleInViewport`, and `_toolbarVisibleInViewport` value notifiers. Handles/toolbars are automatically clipped/hidden when scrolled out of view.

3. **Toolbar Position Displacement Bug**
   - *Issue:* When selected text is partially offscreen, the context menu is placed relative to the text's layout block, positioning the menu offscreen or misaligning it.
   - *Fix:* Introduced `_visibleSelectedGlobalRect()` to anchor the context toolbar directly above the *visible* region of the selection inside the viewport.

4. **Multi-Widget Selection Gaps Bug**
   - *Issue:* Dragging selection quickly across multiple distinct child widgets often skips frame updates, leaving intermediate paragraphs unselected.
   - *Fix:* Implemented `_ensureInteriorSelectablesUpdated()` to contiguously dispatch selection updates to all intermediate components in the selection range.

5. **Deselection on Web Scroll/Drag Gestures Bug**
   - *Issue:* Clicking/tapping outside the selectable region drops focus and deselects text on Flutter Web. However, drag-scrolling on mobile or trackpads triggers this boundary check, causing selections to drop during a scroll event.
   - *Fix:* Added pointer router listeners with dynamic drag slop thresholds (`8.0` for precise mouse pointers, `20.0` for fingers and touch input) so that drag-scrolling does not drop active selections, while deliberate taps still behave correctly.

## Maintenance and Upstream Audits

To make it easy to audit upstream changes or compare customizations when upgrading Flutter versions:
* The unmodified version of the file from the Flutter SDK is kept alongside the fork as [selectable_region_original.dart](file:///d:/flutter/personal_webpage/packages/tw_primitives/lib/src/selection/selectable_region_original.dart).
* To check what customizations have been introduced relative to the original implementation:
  ```powershell
  git diff --no-index packages/tw_primitives/lib/src/selection/selectable_region_original.dart packages/tw_primitives/lib/src/selection/selectable_region_fork.dart
  ```
