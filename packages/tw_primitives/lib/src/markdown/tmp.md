Short answer — consumers can override at two levels: high-level surface config (recommended) and low-level theme/style objects (full control). Current override points:

- High-level surface (use `buildMarkdownSurfaceStyle`):
  - `MarkdownThemeConfig.baseTextColor` — base text color for the surface.
  - `MarkdownThemeConfig.linkColor` — link color used for link text/underline.
  - `MarkdownThemeConfig.isDark` — brightness hint (affects strong/strike thickness choice).
  - `MarkdownThemeConfig.textScale` — base text scale passed into the builder.
  - `MarkdownThemeConfig.linkPillStyle` — optional `MarkupLinkPillStyle` to override pill visuals.
  - `buildMarkdownSurfaceStyle(...)` — builds a surface `MarkdownSurfaceStyle`; supply overrides via `MarkdownThemeConfig` (colors, brightness, textScale) instead of injecting a base `TextStyle`.

- Widget-level inputs (when rendering):
  - `MarkupView` params:
    - `theme` — a `MarkupTheme` (usually from the surface builder) — full theme object.
    - `gestureRecognizerFactory` — factory to supply `GestureRecognizer` for links (how links open/are handled).
    - `selectable` — whether the markup is selectable (affects copy/selection UX).
    - `chromeVisible` — whether decorative chrome (rail, paddings) should be visible.
    - `blockquoteRailColor` — optional override color for the blockquote rail.
    - `textAlign` — alignment for rendered text.

- Theme & pill customization:
  - `MarkupTheme` fields (returned by the builder) you can tweak if you need deeper control: `baseStyle`, `strongStyle`, `emphasisStyle`, `strikethroughStyle`, `underlineStyle`, `linkStyle`, `blockquoteStyle`, and `headingStyleResolver`.
  - `MarkupLinkPillStyle` fields you can set/copyWith: `fillColor`, `borderColor`, `borderWidth`, `padding`, `shadows`, `textStyle`.

- Gesture & interaction:
  - `gestureRecognizerFactory` is the primary extension point for link behavior (open externally, copy, track analytics, etc.).

- Notes / guidance:
  - Preferred flow: call `buildMarkdownSurfaceStyle(MarkdownThemeConfig(...))` and pass the resulting `theme` and `bodyTextStyle` into `MarkupView`. This keeps consumers out of internals and avoids needing tokens.
  - If you need extreme customization, you may construct/modify a `MarkupTheme` yourself and pass it to `MarkupView` — but that is the low-level route.
  - Tokens and decoration geometry (underline/strike thickness, layout factors) are intentionally internal to `MarkupViewStyle` and should not be consumed externally.

If you want, I can:
- Produce a tiny example `tw_chat` snippet showing the recommended usage with `buildMarkdownSurfaceStyle` + `MarkupView`.
- Add a short doc comment or README in tw_primitives describing these override points. Which would you prefer?






---

Yes — consumers already override several high-level markdown inputs. Summary with examples:

- **Base text style:** The builder returns a `bodyTextStyle` derived from `TwTextStyles` and the `MarkdownThemeConfig` (color/scale/brightness). See privacy_cookies_modal.dart and message_bubble.dart.  
- **Blockquote color:** `blockquoteRailColor` is passed into `MarkupView` (usually `markdownSurface.blockquoteRailColor`). See landing_page.dart and message_bubble.dart.  


- **Link pill visuals:** `MarkdownThemeConfig.linkPillStyle` / `MarkupLinkPillStyle` (fillColor, borderColor, textStyle, shadows). See landing_page.dart and message_bubble.dart.  
- **Surface colors / mode / scale:** `MarkdownThemeConfig` fields (`baseTextColor`, `linkColor`, `isDark`, `textScale`) are supplied at each call site (e.g. message_bubble.dart).  
- **Link behavior:** `gestureRecognizerFactory` passed to `MarkupView` to control link handling. Example: landing_page.dart and message_bubble.dart.  
- **Interaction flags:** `selectable` and `chromeVisible` are set by consumers (e.g. message bubbles set selectable true/false and chromeVisible true/false). See message_bubble.dart.  
- **Full-theme overrides / tweaks:** Some code builds or mutates a `MarkupTheme` directly for special cases (e.g. `_transparentMarkupTheme` in message_bubble.dart and tests that construct `MarkupTheme`).

In short: consumers do not need token-level access — they already override high-level inputs (colors, base TextStyle, pill style, gesture factory, and visibility/selection flags). If you want, I can (1) produce a minimal example showing the recommended pattern, or (2) add documentation listing these override points. Which do you prefer?