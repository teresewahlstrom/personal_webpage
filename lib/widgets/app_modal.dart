import 'package:flutter/material.dart';
import 'package:tw_primitives/theme.dart';

import '../config/app_ui_config.dart';
import '../services/keyboard_height.dart';

typedef AppModalChildBuilder =
    Widget Function(BuildContext context, VoidCallback close);

Future<void> showAppModal({
  required BuildContext context,
  required AppModalChildBuilder builder,
  String? headerTitle,
}) {
  final Size viewportSize = MediaQuery.of(context).size;
  return showDialog<void>(
    context: context,
    barrierColor: ModalUiConfig.barrierColor,
    useSafeArea: true,
    builder: (BuildContext dialogContext) {
      void close() => Navigator.of(dialogContext).pop();
      return _AppModalFrame(
        backgroundColor: context.twColors.modalBackground,
        frameBorder: AppLineStyle(
          color: context.twColors.lineSubtle,
          width: AppLineTheme.subtleWidth,
        ),
        headerBorderColor: context.twColors.modalHeaderBorder,
        closeIconColor: context.twColors.modalCloseIcon,
        closeIconHoverColor: context.twColors.modalCloseIconHover,
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

class _AppModalFrame extends StatelessWidget {
  const _AppModalFrame({
    required this.backgroundColor,
    required this.frameBorder,
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
  final AppLineStyle frameBorder;
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
  Widget build(BuildContext context) {
    final Size viewportSize = MediaQuery.of(context).size;
    final double keyboardHeight = KeyboardHeight.of(context);
    final double availableHeight = viewportSize.height - keyboardHeight;
    return Dialog(
      backgroundColor: backgroundColor,
      insetPadding: insetPadding,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: frameBorder.borderSide,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: availableHeight * maxHeightFactor,
        ),
        child: Column(
          children: <Widget>[
            Container(
              height: ModalUiConfig.headerHeight,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: headerBorderColor, width: 1),
                ),
              ),
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: headerTitle == null
                        ? const SizedBox.shrink()
                        : Text(
                            headerTitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TwTextStyles.of(context).modalHeaderTitle(
                              color: context.twColors.pageBodyText,
                            ),
                          ),
                  ),
                  _ModalCloseButton(
                    onTap: close,
                    color: closeIconColor,
                    hoverColor: closeIconHoverColor,
                  ),
                ],
              ),
            ),
            Expanded(
              child: DefaultTextStyle(
                style: TwTextStyles.of(context).bodyForContext(
                  context: context,
                  color: context.twColors.pageBodyText,
                ),
                child: Padding(
                  padding: contentPadding,
                  child: builder(context, close),
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
            style: TwTextStyles.of(context).modalCloseGlyph(
              color: _isHovered ? widget.hoverColor : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
