# Flutter Web Bottom UI Jump Audit

**Date**: 2026-05-15  
**Thoroughness**: Medium  
**Focus**: Viewport-locked positioning and dynamic height calculations

---

## Executive Summary

Found **5 high-risk viewport-dependent patterns** that can trigger UI jumps when viewport dimensions change (mobile keyboard show/hide, scrollbar appearance, responsive breakpoint shifts):

1. **Chat dock bottom offset** (PRIMARY RISK) — viewport width determines offset
2. **Modal height factor** — tied to viewport height at modal open time
3. **Landing page placeholder height** — uses viewport.height calculation
4. **ConstrainedBox minHeight pattern** — recalculates on parent height changes
5. **Missing web CSS constraints** — html/body have no explicit sizing

---

## Location-by-Location Findings

### 1. [lib/widgets/shell/_chat_overlay.dart](lib/widgets/shell/_chat_overlay.dart#L46-L65) — Chat Dock Positioning

**CURRENT PATTERN:**
```dart
final double floatingInset = FloatingControlInset.forViewportWidth(
  viewport.width,
);
return ChatDock(
  ...
  minimizedBottomOffset: floatingInset,  // ← viewport width → bottom position
  minimizedRightInset: floatingInset,
  ...
);
```

**RISK: UI Jump Trigger**
- `floatingInset` is **calculated from `viewport.width` every rebuild**
- When viewport width changes (mobile orientation flip, scrollbar show/hide, browser resize), `floatingInset` recalculates
- ChatDock bottom position shifts → visual jump of chat widget
- **Jump scenarios:**
  - Mobile keyboard show: viewport width narrows → `floatingInset` drops from 25→16→12→10 → chat jumps left & up
  - Scrollbar appearance: web viewport narrows → same cascading offset change
  - Responsive breakpoint (900px threshold exists in LandingPage) → abrupt inset change

**Evidence chain:**
- `FloatingControlInset.forViewportWidth()` returns 10/12/16/25 based on width thresholds [_floating_controls.dart#L21-L29]
- Different width → different offset → chat position resets

---

### 2. [lib/widgets/shell/_chat_overlay.dart](lib/widgets/shell/_chat_overlay.dart#L36-L38) — Floating Inset Calculation

**CURRENT PATTERN:**
```dart
final Size viewport = MediaQuery.of(context).size;  // Full viewport at animation frame
final double floatingInset = FloatingControlInset.forViewportWidth(viewport.width);
```

**RISK: Stale Viewport Reference**
- `viewport.width` captured once per build, but CSS scrollbar changes can fire mid-animation
- Flutter's ScrollBar widget toggling can cause brief viewport reflow
- Chat offset stored/animated before new width is known → position lag + correction jump

---

### 3. [lib/pages/landing_page.dart](lib/pages/landing_page.dart#L122) — Landing Page Placeholder Height

**CURRENT PATTERN:**
```dart
} else if (!snapshot.hasData) {
  content = SizedBox(
    height: (viewport.height * 0.72).clamp(320.0, 860.0),
  );
```

**RISK: UI Jump on Keyboard/Orientation**
- Placeholder reserves `viewport.height * 0.72` before data loads
- When keyboard appears (mobile), `viewport.height` shrinks → placeholder height shrinks → page reflows
- When data arrives while keyboard is open, layout jumps to actual content
- **Jump scenarios:**
  - Mobile focus on form input: viewport height drops ~50% → placeholder collapses
  - Keyboard close before data ready: viewport height restores → placeholder expands
  - Orientation change mid-load: height recalculates → jump

---

### 4. [lib/widgets/shell/page_scaffold.dart](lib/widgets/shell/page_scaffold.dart#L132-L155) — Full-Height Column with Expanded

**CURRENT PATTERN:**
```dart
Column(
  children: <Widget>[
    Expanded(
      child: Stack(
        children: <Widget>[
          AbsorbPointer(
            child: PrimaryScrollController(
              ...
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,  // ← fills viewport
                  ),
```

**RISK: Height Recalculation Cascade**
- `Expanded` fills available space from parent `Column`
- `ConstrainedBox` enforces `minHeight: constraints.maxHeight` (current Expanded height)
- When viewport height changes (keyboard, orientation), `Expanded` height recomputes → `ConstrainedBox` height recomputes → entire scroll layout reflows
- **Jump scenarios:**
  - Mobile keyboard show: `Expanded` height shrinks 50% → all child heights recalculate
  - Scrollbar auto-hide on idle: web viewport width changes imperceptibly → causes height recalc loop
  - Theme switch animation: `FadeTransition` parent rebuild → potential height recalc mid-animation

---

### 5. [lib/widgets/app_modal.dart](lib/widgets/app_modal.dart#L18-L21) — Modal Height Binding

**CURRENT PATTERN:**
```dart
final Size viewportSize = MediaQuery.of(context).size;
return showDialog<void>(
  ...
  maxHeightFactor: ModalUiConfig.maxHeightFactorFor(viewportSize),
```

**RISK: Modal Resize During Interaction**
- Modal max height is calculated **once at open time** from `viewportSize`
- If user opens modal with keyboard hidden, modal is sized for full viewport
- User taps input field → keyboard appears → viewport height shrinks
- Modal is locked to old height → modal content now exceeds available space → jump or clipping
- **Jump scenarios:**
  - Open newsletter modal on desktop → switch to mobile view → keyboard appears → modal overflows
  - Compact viewport (height ≤ 760px) uses `maxHeightFactorCompact = 0.96` — modal nearly fills screen → no room for keyboard

---

### 6. [web/index.html](web/index.html#L1-14) — Missing HTML/Body Sizing Constraints

**CURRENT PATTERN:**
```html
<!DOCTYPE html>
<html>
  <head>
    <base href="$FLUTTER_BASE_HREF" />
    <meta charset="UTF-8" />
    ...
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  </head>
  <body>
    <script src="flutter_bootstrap.js" async></script>
  </body>
</html>
```

**RISK: Browser Default Spacing & Scrollbar Shifts**
- No explicit `html { height: 100%; margin: 0; }` or `body { height: 100%; margin: 0; }`
- Browser applies default body margin (typically 8px) → Flutter app doesn't fill edge-to-edge
- Scrollbar appearance/disappearance causes 15px horizontal reflow (desktop) → viewport width shifts → cascade to all width-dependent layouts (chat offset, breakpoints)
- **Jump scenarios:**
  - Page content grows beyond viewport → scrollbar appears → web viewport narrows 15px → chat offset recalculates → visible jump
  - Keyboard input changes scroll state → scrollbar toggles → jump
  - (iOS) ViewInsets from keyboard not accounted for in CSS → layout confusion

---

### 7. [lib/widgets/shell/page_scaffold.dart](lib/widgets/shell/page_scaffold.dart#L200-L202) — Theme Toggle Fixed Position

**CURRENT PATTERN:**
```dart
Positioned(
  right: mediaQuery.viewPadding.right + floatingInset,
  top: mediaQuery.viewPadding.top + floatingInset,
  child: ThemeToggleControlButton(...),
)
```

**RISK: Inset Dependency**
- Position tied to `viewPadding` (safe area insets) + `floatingInset`
- If `floatingInset` recalculates due to width change, toggle button jumps right
- Not a bottom element, but contributes to overall layout instability visual pattern

---

## Risk Summary Table

| Location | Pattern | Jump Type | Severity |
|----------|---------|-----------|----------|
| _chat_overlay.dart | `minimizedBottomOffset = floatingInset(viewport.width)` | Lateral + vertical | **HIGH** |
| _chat_overlay.dart | Viewport.width captured once per build | Stale reference | **HIGH** |
| landing_page.dart | `height = viewport.height * 0.72` placeholder | Vertical collapse/expand | **MEDIUM** |
| page_scaffold.dart | `Expanded` + `ConstrainedBox(minHeight)` cascade | Full layout reflow | **MEDIUM** |
| app_modal.dart | Modal height locked at open time | Overflow/resize jump | **MEDIUM** |
| web/index.html | No explicit html/body sizing | Scrollbar shifts 15px | **MEDIUM** |
| page_scaffold.dart | Theme toggle position depends on floatingInset | Lateral jump | **LOW** |

---

## Recommended Investigation Steps

### Immediate (High Confidence)
1. **Test mobile keyboard scenario**: Open landing page on mobile, tap form input (newsletter modal) → observe bottom chat dock position before/after keyboard
2. **Test web scrollbar scenario**: Resize browser window to trigger scrollbar appearance (content > viewport)
3. **Check tw_chat package**: Verify `ChatDock` doesn't have internal viewport-watching that conflicts with parent inset changes

### Secondary (Medium Confidence)
4. Audit `flutter_bootstrap.js` and `flutter_service_worker.js` for viewport resize event hooks
5. Check if `MediaQuery.viewInsets` (keyboard height) is being observed anywhere and causing rebuilds
6. Test modal open on mobile with keyboard: open modal → tap input → keyboard appears

### Long-Term (Root-Cause Fix)
7. Decouple chat offset from `floatingInset(viewport.width)` — use fixed safe-area insets or stable constant
8. Add HTML/body CSS constraints to stabilize web viewport
9. Consider memoizing `FloatingControlInset` calculations to detect width changes explicitly

---

## Notes

- **No hard-coded `bottom:` positioning found** in shell/footer widgets (good practice)
- **Footer is stable**: uses `Container` with fixed `minHeight` and explicit padding
- **Modal stacking**: `Dialog` uses `useSafeArea: true` (correct), but doesn't re-measure on keyboard
- **Page scaffold structure is sound** (column → expanded → scrollview pattern is correct), but the width-dependent offsets undermine it

