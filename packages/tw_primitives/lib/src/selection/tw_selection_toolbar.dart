import 'package:flutter/material.dart';
import 'package:follow_the_leader/follow_the_leader.dart';
import 'package:tw_primitives/theme.dart';

import 'android_popover_toolbar.dart';

class TwSelectionFloatingToolbar extends StatefulWidget {
  const TwSelectionFloatingToolbar({
    super.key,
    this.focalPoint,
    this.floatingToolbarKey,
    this.onCutPressed,
    this.onCopyPressed,
    this.onPastePressed,
    this.onSelectAllPressed,
  });

  final Key? floatingToolbarKey;
  final LeaderLink? focalPoint;

  final VoidCallback? onCutPressed;
  final VoidCallback? onCopyPressed;
  final VoidCallback? onPastePressed;
  final VoidCallback? onSelectAllPressed;

  @override
  State<TwSelectionFloatingToolbar> createState() =>
      _TwSelectionFloatingToolbarState();
}

class _TwSelectionFloatingToolbarState
    extends State<TwSelectionFloatingToolbar> {
  /// Whether the toolbar is above or below the focal point.
  ///
  /// This is used to determine the position of the back button in the overflow
  /// menu.
  bool _isAbove = true;

  @override
  void initState() {
    super.initState();
    widget.focalPoint?.addListener(_onFocalPointChange);
  }

  @override
  void didUpdateWidget(TwSelectionFloatingToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focalPoint != widget.focalPoint) {
      oldWidget.focalPoint?.removeListener(_onFocalPointChange);
      widget.focalPoint?.addListener(_onFocalPointChange);
    }
  }

  @override
  void dispose() {
    widget.focalPoint?.removeListener(_onFocalPointChange);
    super.dispose();
  }

  void _onFocalPointChange() {
    final leader = widget.focalPoint?.leader;
    if (leader == null) {
      return;
    }

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) {
      return;
    }

    final leaderOffset = leader.offset;
    final followerOffset = box.localToGlobal(Offset.zero);
    final isAbove = followerOffset < leaderOffset;

    if (isAbove != _isAbove) {
      setState(() {
        _isAbove = isAbove;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use semantic color token for selection toolbar primary color.
    final Color primaryText = context.twColors.pageBodyText;
    final buttons = <_ButtonViewModel>[
      if (widget.onCutPressed != null)
        _ButtonViewModel(onPressed: widget.onCutPressed!, title: 'Cut'),
      if (widget.onCopyPressed != null)
        _ButtonViewModel(onPressed: widget.onCopyPressed!, title: 'Copy'),
      if (widget.onPastePressed != null)
        _ButtonViewModel(onPressed: widget.onPastePressed!, title: 'Paste'),
      if (widget.onSelectAllPressed != null)
        _ButtonViewModel(
          onPressed: widget.onSelectAllPressed!,
          title: 'Select All',
        ),
    ];

    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: context.twBrightness,
          seedColor: primaryText,
        ),
      ),
      child: KeyedSubtree(
        key: widget.floatingToolbarKey,
        child: AndroidPopoverToolbar(
          isAbove: _isAbove,
          toolbarBuilder: _defaultToolbarBuilder,
          children: [
            for (int i = 0; i < buttons.length; i++)
              TextSelectionToolbarTextButton(
                padding: TextSelectionToolbarTextButton.getPadding(
                  i,
                  buttons.length,
                ),
                onPressed: buttons[i].onPressed,
                alignment: AlignmentDirectional.center,
                child: Text(buttons[i].title),
              ),
          ],
        ),
      ),
    );
  }
}

Widget _defaultToolbarBuilder(BuildContext context, Widget child) {
  return AndroidPopoverToolbarContainer(child: child);
}

class _ButtonViewModel {
  _ButtonViewModel({required this.title, required this.onPressed});

  final String title;
  final VoidCallback onPressed;
}
