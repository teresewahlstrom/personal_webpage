import 'package:flutter/material.dart';
import '../colors/router.dart';
import '../text_styles/router.dart';

class TwExpandableCard extends StatefulWidget {
  const TwExpandableCard({
    super.key,
    required this.title,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
  });

  final String title;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;

  @override
  State<TwExpandableCard> createState() => _TwExpandableCardState();
}

class _TwExpandableCardState extends State<TwExpandableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final tokens = TwTextStyleTokens.forBrightness(
      Theme.of(context).brightness,
    );
    final baseStyle = TwTextStyles.of(context).bodyForContextless(
      color: context.twColors.pageBodyText,
      textScale:
          MediaQuery.textScalerOf(context).scale(tokens.twBodyBaseFontSize) /
          tokens.twBodyBaseFontSize,
    );
    final h2 = TwTextStyles.of(context).h2From(baseStyle);
    final TextStyle cardTitleStyle = TwTextStyles.of(context).cardTitleFrom(h2).copyWith(
      color: _isHovered ? context.twColors.linkTextHover : null,
    );

    final DefaultSelectionStyle inheritedSelectionStyle =
        DefaultSelectionStyle.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: context.twColors.transparent,
        child: DefaultSelectionStyle(
          selectionColor: inheritedSelectionStyle.selectionColor,
          cursorColor: inheritedSelectionStyle.cursorColor,
          mouseCursor: SystemMouseCursors.click,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: InkWell(
              onTap: widget.onTap,
              child: Padding(
                padding: widget.padding,
                child: Opacity(
                  opacity: context.twColors.cardMarkdownOpacity,
                  child: Text(widget.title, style: cardTitleStyle),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
