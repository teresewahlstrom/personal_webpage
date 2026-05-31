import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:overlord/follow_the_leader.dart';
import 'package:overlord/overlord.dart';
import 'package:tw_primitives/theme.dart';

class IOSTextEditingFloatingToolbar extends StatelessWidget {
  const IOSTextEditingFloatingToolbar({
    super.key,
    this.floatingToolbarKey,
    required this.focalPoint,
    this.onCutPressed,
    this.onCopyPressed,
    this.onPastePressed,
  });

  final Key? floatingToolbarKey;

  /// Direction that the toolbar arrow should point.
  final LeaderLink focalPoint;

  final VoidCallback? onCutPressed;
  final VoidCallback? onCopyPressed;
  final VoidCallback? onPastePressed;

  @override
  Widget build(BuildContext context) {
    final tw = context.twColors;

    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: context.twBrightness,
          seedColor: tw.toolbarColor,
        ),
      ),
      child: CupertinoPopoverToolbar(
        key: floatingToolbarKey,
        focalPoint: LeaderMenuFocalPoint(link: focalPoint),
        elevation: 8.0,
        backgroundColor: tw.toolbarColor,
        activeButtonTextColor: tw.pageBodyText,
        inactiveButtonTextColor: tw.pageBodyText.withValues(alpha: 0.7),
        children: [
          if (onCutPressed != null)
            _buildButton(
              context,
              onPressed: onCutPressed!,
              title: 'Cut',
            ),
          if (onCopyPressed != null)
            _buildButton(
              context,
              onPressed: onCopyPressed!,
              title: 'Copy',
            ),
          if (onPastePressed != null)
            _buildButton(
              context,
              onPressed: onPastePressed!,
              title: 'Paste',
            ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, {
    required String title,
    required VoidCallback onPressed,
  }) {
    final labelStyle = TwTextStyles.of(context).adaptBase(
      TwTextStyles.of(context).bodyForContext(context: context, color: context.twColors.toolbarColor),
      fontSize: twToolbarFontSize,
      fontWeight: FontWeight.w300,
    );

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(kMinInteractiveDimension, 0),
        padding: EdgeInsets.zero,
        splashFactory: NoSplash.splashFactory,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Text(title, style: labelStyle),
      ),
    );
  }
}

