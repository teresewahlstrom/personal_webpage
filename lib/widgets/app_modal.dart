import 'package:flutter/material.dart';

import '../config/app_ui_config.dart';
import 'arrow_key_scroll_wrapper.dart';

typedef AppModalChildBuilder =
    Widget Function(BuildContext context, VoidCallback close);

Future<void> showAppModal({
  required BuildContext context,
  required AppModalChildBuilder builder,
  String? headerTitle,
}) {
  final Brightness brightness = Theme.of(context).brightness;
  final Size viewportSize = MediaQuery.of(context).size;
  return showDialog<void>(
    context: context,
    barrierColor: ModalUiConfig.barrierColor,
    useSafeArea: true,
    builder: (BuildContext dialogContext) {
      void close() => Navigator.of(dialogContext).pop();

      return _AppModalFrame(
        backgroundColor: ModalUiConfig.backgroundFor(brightness),
        headerBorderColor: ModalUiConfig.headerBorderFor(brightness),
        closeIconColor: ModalUiConfig.closeIconFor(brightness),
        closeIconHoverColor: ModalUiConfig.closeIconHoverFor(brightness),
        insetPadding: ModalUiConfig.insetPaddingFor(viewportSize),
        contentPadding: ModalUiConfig.contentPaddingFor(viewportSize),
        maxWidth: ModalUiConfig.maxWidth,
        maxHeightFactor: ModalUiConfig.maxHeightFactorFor(viewportSize),
        headerTitle: headerTitle,
        close: close,
        builder: builder,
      );
    },
  );
}

class _AppModalFrame extends StatefulWidget {
  const _AppModalFrame({
    required this.backgroundColor,
    required this.headerBorderColor,
    required this.closeIconColor,
    required this.closeIconHoverColor,
    required this.insetPadding,
    required this.contentPadding,
    required this.maxWidth,
    required this.maxHeightFactor,
    this.headerTitle,
    required this.close,
    required this.builder,
  });

  final Color backgroundColor;
  final Color headerBorderColor;
  final Color closeIconColor;
  final Color closeIconHoverColor;
  final EdgeInsets insetPadding;
  final EdgeInsets contentPadding;
  final double maxWidth;
  final double maxHeightFactor;
  final String? headerTitle;
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
    final Size viewportSize = MediaQuery.of(context).size;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double availableHeight = viewportSize.height - keyboardHeight;
    return Dialog(
      backgroundColor: widget.backgroundColor,
      insetPadding: widget.insetPadding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth,
          maxHeight: availableHeight * widget.maxHeightFactor,
        ),
        child: Column(
          children: <Widget>[
            Container(
              height: ModalUiConfig.headerHeight,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: widget.headerBorderColor, width: 1),
                ),
              ),
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: widget.headerTitle == null
                        ? const SizedBox.shrink()
                        : Text(
                            widget.headerTitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'ComingSoon',
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: widget.closeIconColor,
                              height: 1,
                            ),
                          ),
                  ),
                  _ModalCloseButton(
                    onTap: widget.close,
                    color: widget.closeIconColor,
                    hoverColor: widget.closeIconHoverColor,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ArrowKeyScrollWrapper(
                controller: _modalScrollController,
                child: PrimaryScrollController(
                  controller: _modalScrollController,
                  child: DefaultTextStyle(
                    style: ModalTextStyles.body(context),
                    child: Padding(
                      padding: widget.contentPadding,
                      child: widget.builder(context, widget.close),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModalCloseButton extends StatefulWidget {
  const _ModalCloseButton({
    required this.onTap,
    required this.color,
    required this.hoverColor,
  });

  final VoidCallback onTap;
  final Color color;
  final Color hoverColor;

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
              color: _isHovered ? widget.hoverColor : widget.color,
              fontSize: 28,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
