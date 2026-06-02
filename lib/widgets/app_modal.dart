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

      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        insetPadding: ModalUiConfig.insetPaddingFor(viewportSize),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ModalUiConfig.maxWidth,
            maxHeight:
                availableHeight *
                ModalUiConfig.maxHeightFactorFor(viewportSize),
          ),
          child: TwPanelContainer(
            title: headerTitle == null
                ? null
                : TwPanelTitle(label: headerTitle),
            onClose: close,
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
