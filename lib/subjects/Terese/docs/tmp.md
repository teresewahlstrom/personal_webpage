I did a static audit across the main app, `tw_chat`, and especially `tw_primitives`. No edits made, and I did not run analyzer/tests. I ignored the special chat copy formatter as requested.

**Findings**

1. **High: hybrid PC touch handling still needs a stable textfield design.**
   [tw_textfield.dart](D:/flutter/personal_webpage/packages/tw_primitives/lib/src/text_field/tw_textfield/tw_textfield.dart:331) chooses Android textfield mode for web if the browser reports touch support. Attempts to switch platform implementations per pointer kind caused scroll-controller and gesture-cancel regressions, so this needs a different design than live-swapping the textfield subtree.

2. **High: desktop textfield has no long-press/touch selection path.**
   [desktop_textfield.dart](D:/flutter/personal_webpage/packages/tw_primitives/lib/src/text_field/tw_textfield/desktop/desktop_textfield.dart:1225) wires tap and pan recognizers, but no long-press recognizer. If a touch PC lands in desktop mode, touch editing will feel broken: no long-press word select, no handles, no toolbar.

3. **Medium: desktop textfield right-click has no built-in context menu behavior.**
   [desktop_textfield.dart](D:/flutter/personal_webpage/packages/tw_primitives/lib/src/text_field/tw_textfield/desktop/desktop_textfield.dart:912) delegates right-click to optional tap handlers only. For a custom editable field, this can leave copy/cut/paste behavior inconsistent or absent.

4. **Medium: page and chat selection ownership is asymmetric.**
   [page_scaffold.dart](D:/flutter/personal_webpage/lib/widgets/shell/page_scaffold.dart:128) sets chat target false on page pointer down, but does not obviously clear chat selection. The chat overlay does clear page selection at [page_scaffold.dart](D:/flutter/personal_webpage/lib/widgets/shell/page_scaffold.dart:204). This can leave stale chat selection visible after interacting with the page.

5. **Medium: clickable non-editable text can compete with selection.**
   Project-card headers at [landing_page.dart](D:/flutter/personal_webpage/lib/pages/landing_page.dart:606) and social rows at [landing_page.dart](D:/flutter/personal_webpage/lib/pages/landing_page.dart:911) are inside selectable content but also have tap/gesture behavior. Small drag gestures can become toggles/navigation, and users may find text hard to select.

6. **Medium: collapsed chat bubbles can select more than is visibly shown.**
   [message_bubble.dart](D:/flutter/personal_webpage/packages/tw_chat/lib/src/widgets/message_bubble.dart:557) uses a hidden selectable layer, and [message_bubble.dart](D:/flutter/personal_webpage/packages/tw_chat/lib/src/widgets/message_bubble.dart:715) allows `collapsedVisibleLines + 1`. Selection may include text the user cannot see in the collapsed preview.

7. **Low/Medium: composer shield may block selection hit-testing near the composer boundary.**
   [section.dart](D:/flutter/personal_webpage/packages/tw_chat/lib/src/widgets/section.dart:237) has an `AbsorbPointer` shield around the composer zone. The comment says it protects textfield handles, but if the bounds are off, selection handles or toolbar interactions near that edge could vanish.

8. **Low/Medium: selection overlay refreshes on every scroll update.**
   [selectable_scroll_area.dart](D:/flutter/personal_webpage/packages/tw_primitives/lib/src/scrollbar/selectable_scroll_area.dart:271) refreshes selection geometry during scroll updates/overscroll. This is probably deliberate, but it is a plausible source of toolbar or handle jitter.

9. **Low: newsletter modal is wrapped in selectable infrastructure around an embed.**
   [newsletter_modal.dart](D:/flutter/personal_webpage/lib/modals/newsletter/newsletter_modal.dart:19) puts an embedded newsletter surface inside `TwSelectableScrollArea`. If the embed contains its own inputs/selection, this may create odd focus or right-click behavior for little benefit.
