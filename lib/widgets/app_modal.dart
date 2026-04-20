import 'package:flutter/material.dart';

import '../config/app_ui_config.dart';
import 'arrow_key_scroll_wrapper.dart';

typedef AppModalChildBuilder = Widget Function(
    BuildContext context, VoidCallback close);

Future<void> showAppModal({
  required BuildContext context,
  required AppModalChildBuilder builder,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: ModalUiConfig.barrierColor,
    builder: (BuildContext dialogContext) {
      void close() => Navigator.of(dialogContext).pop();

      return _AppModalFrame(
        backgroundColor: ModalUiConfig.backgroundColor,
        insetPadding: ModalUiConfig.insetPadding,
        contentPadding: ModalUiConfig.contentPadding,
        maxWidth: ModalUiConfig.maxWidth,
        maxHeightFactor: ModalUiConfig.maxHeightFactor,
        close: close,
        builder: builder,
      );
    },
  );
}

class _AppModalFrame extends StatefulWidget {
  const _AppModalFrame({
    required this.backgroundColor,
    required this.insetPadding,
    required this.contentPadding,
    required this.maxWidth,
    required this.maxHeightFactor,
    required this.close,
    required this.builder,
  });

  final Color backgroundColor;
  final EdgeInsets insetPadding;
  final EdgeInsets contentPadding;
  final double maxWidth;
  final double maxHeightFactor;
  final VoidCallback close;
  final AppModalChildBuilder builder;

  @override
  State<_AppModalFrame> createState() => _AppModalFrameState();
}

class _AppModalFrameState extends State<_AppModalFrame> {
  final ScrollController _modalScrollController = ScrollController();

  @override
  void dispose() {
    _modalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.backgroundColor,
      insetPadding: widget.insetPadding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth,
          maxHeight:
              MediaQuery.of(context).size.height * widget.maxHeightFactor,
        ),
        child: ArrowKeyScrollWrapper(
          controller: _modalScrollController,
          child: PrimaryScrollController(
            controller: _modalScrollController,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: widget.contentPadding,
                  child: widget.builder(context, widget.close),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _ModalCloseButton(onTap: widget.close),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalCloseButton extends StatefulWidget {
  const _ModalCloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_ModalCloseButton> createState() => _ModalCloseButtonState();
}

class _ModalCloseButtonState extends State<_ModalCloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            "×",
            style: TextStyle(
              color: _isHovered
                  ? ModalUiConfig.closeIconHoverColor
                  : ModalUiConfig.closeIconColor,
              fontSize: 28,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
