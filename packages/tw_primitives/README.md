# tw_primitives

Internal primitives package for the personal_webpage Flutter app. Contains reusable UI components and utilities.

## Structure

### `tw_textfield`

Provides styled text input components with platform-specific support (Android, iOS, desktop). This subtree contains the extracted text-field implementation used by `tw_chat`, and future unrelated code should live beside it as a separate sibling subtree.

**Public API:**
- `TwTextField` — platform-adaptive text field with attributed text support
- `AttributedTextEditingController` — manages styled text with metadata
- `HintBehavior` — controls hint text display timing
- `CaretStyle` — caret appearance configuration
- `BlinkTimingMode` — cursor blink behavior
- And related infrastructure components

## Usage

Import the text field API from `text_field.dart`:

```dart
import 'package:tw_primitives/text_field.dart';
```

This provides a stable API boundary and makes the dependency relationship clearer: `tw_chat` depends on `tw_primitives`, which now owns the extracted text-field code.

## Architecture Note

This package now contains the extracted implementation directly. If further pruning removes more unused editor code, the public exports here should stay stable while the internal tree gets smaller.

## Third-Party Notices

Code in the `TwTextField` subtree is derived in part from `super_editor`.
See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for attribution and the full MIT license text.
