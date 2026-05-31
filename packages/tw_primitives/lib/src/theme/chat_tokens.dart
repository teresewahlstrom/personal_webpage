import 'package:flutter/material.dart';

/// Shared chat-specific tokens exported for consumers like `tw_chat`.
/// These provide canonical defaults so chat packages don't hardcode numbers.

// Jump-to-latest button tokens
const double twChatJumpToLatestButtonRightInset = 14.0;
const double twChatJumpToLatestButtonBottomInset = 10.0 / 3.0;
const double twChatJumpToLatestButtonFixedSize = 34.0;
const double twChatJumpToLatestButtonIconRatio = 0.55;
const double twChatJumpToLatestButtonElevation = 0.0;
const EdgeInsets twChatJumpToLatestButtonPadding = EdgeInsets.zero;

// Markup decoration biases (shared helpers for chat rendering)
// NOTE: markup decoration tokens moved to the markdown package surface.
// These constants were intentionally removed so chat uses the canonical
// tokens from `tw_primitives`'s markdown module.
