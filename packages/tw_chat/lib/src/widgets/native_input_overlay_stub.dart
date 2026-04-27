import 'package:flutter/widgets.dart';

/// Non-web stub: the overlay is a no-op and [child] is returned unchanged.
///
/// The web implementation lives in `native_input_overlay_web.dart` and is
/// selected by the conditional export in `native_input_overlay.dart`.
class NativeInputOverlay extends StatelessWidget {
  const NativeInputOverlay({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.child,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
