Audit summary — places still needing centralization into text_styles (excluding `tw_keywords`)

Findings (high priority)
- markup_theme_builder.dart
  - Imports internal _dark.dart to read `twBodyBaseFontSize` for `bodyTextScaleOf`.
  - Action: remove internal import; either compute scale from `TwTextStyles` public API or expose `twBodyBaseFontSize` (or a `baseBodySize` accessor) via the public router.

- `packages/tw_primitives/lib/src/text_field/*`
  - `infrastructure/hint_text.dart` and styles.dart call `TwTextStyles.forBrightness(Brightness.light)` and then apply many hard-coded header/font sizes (24, 18, 20, etc).
  - Action: centralize header/hint font-size tokens and header weight/line-height tokens in `text_styles` (expose defaults for contextless use), then use those tokens here instead of magic numbers.

Medium / contextual items to consider centralizing
- skin_shared.dart
  - Chat skin currently creates a base `TextStyle` from `TwTextStyles.forBrightness` then overrides `fontSize: 13`, `height: 1.12`, weight, etc.
  - Action: decide whether chat-specific tokens should live in `tw_chat` (acceptable) or move common numeric tokens (e.g., small body size) into `tw_primitives` tokens for reuse.

- desktop_textfield.dart
  - Uses `textStyle.fontFamily` / fontSize when reporting to IME; okay, but consider ensuring `twFontFamily` flows consistently into all text-field defaults.

Low / test-only (no centralization required)
- Tests under `packages/tw_primitives/test/markdown/*` define many `TextStyle` constants for assertions — keep as-is (tests can use local fixtures).
- Example comments or sample usages in `packages/tw_primitives/lib/src/selection/*` — ignore.

What we already fixed
- main.dart no longer imports `lib/src` internals; `twFontFamily` is now publicly available via the text_styles router.
- landing_page.dart, app_modal.dart, and other app callers use `TwTextStyles.of(context)`.

Concrete recommendations (next steps)
1. Add public accessors in router.dart for frequently needed token values:
   - `twBodyBaseFontSize`, `twSectionBaseFontSize`, `twFooterBaseFontSize`, `twModalHeaderFontSize`, plus line-heights and default font-weights (or a small `Tokens` struct).
   - Or add named getters on `TwTextStyles` (e.g., `TwTextStyles.bodyBaseSize`).

2. Replace the _dark.dart import in markup_theme_builder.dart with the public API (either `TwTextStyles.forBrightness(...).bodyForContextless(...)` to derive scale, or the new base-size accessors).

3. Move hard-coded header/hint sizes in `packages/tw_primitives/lib/src/text_field/*` into tokens exposed by `text_styles` and use them in `defaultHintStyleBuilder` and `defaultTextFieldStyleBuilder`.

4. Scan tw_chat and other packages for repeated numeric font sizes and decide per-package whether to:
   - Reference `tw_primitives` tokens (if shared), or
   - Keep as package-local tokens (if chat-specific).

5. After token exposure and replacements, run `dart analyze` / `flutter analyze` and targeted tests to validate.

Updated todo list
- I added actionable tasks to the repo plan (items 9–13) to implement the above steps.

If you want, I can:
- Implement step 1 and 2 now (expose the base-size tokens via the router and remove the _dark.dart import in markup_theme_builder.dart), then run the analyzer and report results. Proceed?