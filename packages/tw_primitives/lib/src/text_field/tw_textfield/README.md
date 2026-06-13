# TwTextField Notes

`TwTextField` is an internal text-field implementation derived in part from `super_editor` and maintained as part of `tw_primitives`.

## Mobile Web Keyboard Lifecycle

`TwTextField` owns cleanup of text-input state when the app leaves the foreground.

This exists because Flutter Web mobile browsers can resume from lock/unlock with stale keyboard state:

1. A text field has focus and the software keyboard is open.
2. The phone is locked.
3. The app resumes after unlock.
4. The real keyboard is gone, but Flutter Web or the browser can still believe an editable element / IME connection is active.
5. The page can keep a persistent white keyboard-height gap.

The fix lives in the primitive text field layer:

- `infrastructure/text_input_lifecycle.dart` decides which lifecycle states clear text input.
- Android and iOS `TwTextField` implementations call the same cleanup helper.
- The helper clears browser editable focus on web, unfocuses the Flutter field, detaches IME, clears selection/composing state, and removes editing overlays.

Keep this responsibility here. App-level services may measure keyboard height for layout, but they should not know about Flutter Web hidden editable elements or `TwTextField` IME internals.

## Related Docs

- `packages/tw_primitives/THIRD_PARTY_NOTICES.md`
- `packages/tw_primitives/lib/src/text_field/README.md`
