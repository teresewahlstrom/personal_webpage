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
  EdgeInsets? contentPadding,
}) {
  final Size viewportSize = MediaQuery.of(context).size;
  return showDialog<void>(
    context: context,
    barrierColor: ModalUiConfig.barrierColor,
    useSafeArea: true,
    builder: (BuildContext dialogContext) {
      void close() => Navigator.of(dialogContext).pop();
      final double keyboardHeight = KeyboardHeight.of(dialogContext);
      final double availableHeight = viewportSize.height - keyboardHeight;
      final EdgeInsets inset = ModalUiConfig.insetPaddingFor(viewportSize);
      final double maxHeight = availableHeight - (inset.top + inset.bottom);

      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        insetPadding: inset,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ModalUiConfig.maxWidth,
            maxHeight: maxHeight,
          ),
          child: TwPanelContainer(
            title: headerTitle == null
                ? null
                : TwPanelTitle(label: headerTitle),
            onClose: close,
            closeIconSize: 19,
            padding:
                contentPadding ?? ModalUiConfig.contentPaddingFor(viewportSize),
            body: DefaultTextStyle(
              style: TwTextStyles.of(dialogContext).bodyForContext(
                context: dialogContext,
                color: dialogContext.twColors.pageBodyText,
              ),
              child: builder(dialogContext, close),
            ),
          ),
        ),
      );
    },
  );
}
