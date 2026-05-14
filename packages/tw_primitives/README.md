# tw_primitives

Internal primitives package for the personal_webpage Flutter app. Contains reusable UI components and utilities.

## Structure

### `text_field`

Provides styled text input components with platform-specific support (Android, iOS, desktop). The module now contains the extracted text-field implementation used by `tw_chat`, giving consumers a stable interface without exposing unrelated editor subsystems.

**Public API:**
- `SuperTextField` — platform-adaptive text field with attributed text support
- `AttributedTextEditingController` — manages styled text with metadata
- `HintBehavior` — controls hint text display timing
- `CaretStyle` — caret appearance configuration
- `BlinkTimingMode` — cursor blink behavior
- And related infrastructure components

## Usage

Instead of importing directly from `tw_super_editor`:

```dart
// ❌ Before (tw_chat)
import 'package:tw_super_editor/chat_api.dart';

// ✅ After
import 'package:tw_primitives/tw_primitives.dart';
```

This provides a stable API boundary and makes the dependency relationship clearer: `tw_chat` depends on `tw_primitives`, which now owns the extracted text-field code.

## Architecture Note

This package now contains the extracted implementation directly. If further pruning removes more unused editor code, the public exports here should stay stable while the internal tree gets smaller.
