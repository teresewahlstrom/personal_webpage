import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tw_primitives/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialCard extends StatelessWidget {
  const SocialCard({super.key});

  Future<void> _launchUrl(BuildContext context, String rawUrl) async {
    final Uri uri = Uri.parse(rawUrl);
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $rawUrl')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $rawUrl')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<SocialItem> entries = <SocialItem>[
      SocialItem(
        icon: const Icon(Icons.email_outlined),
        label: "terese@t1grid.com",
        copyUrl: "mailto:terese@t1grid.com",
        onTap: () => _launchUrl(context, "mailto:terese@t1grid.com"),
      ),
      SocialItem(
        icon: const Icon(Icons.phone_outlined),
        label: "+46 709 800 525",
        copyUrl: "tel:+46709800525",
        onTap: () => _launchUrl(context, "tel:+46709800525"),
      ),
      SocialItem(
        icon: const Icon(Icons.calendar_month_outlined),
        label: "Video meeting",
        copyUrl: "https://cal.com/teresew/discuss",
        onTap: () => _launchUrl(context, "https://cal.com/teresew/discuss"),
      ),
      SocialItem(
        icon: const FaIcon(FontAwesomeIcons.linkedin),
        label: "LinkedIn",
        copyUrl: "https://www.linkedin.com/in/teresewahlstrom",
        onTap: () => _launchUrl(context, "https://www.linkedin.com/in/teresewahlstrom"),
      ),
    ];

    return IntrinsicWidth(
      child: Material(
        color: context.twColors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: context.twColors.botBubbleBorder, width: 1.0),
          borderRadius: BorderRadius.circular(6),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < entries.length; i++) ...<Widget>[
              SocialRow(entry: entries[i]),
              if (i < entries.length - 1) ...<Widget>[
                Divider(
                  height: 1,
                  thickness: 1,
                  color: context.twIsDark
                      ? context.twColors.gridLine
                      : context.twColors.botBubbleBorder.withValues(alpha: 0.5),
                ),
                const SelectableCopyBreak(height: 0, lineBreaks: 1),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class SocialRow extends StatefulWidget {
  const SocialRow({super.key, required this.entry});

  final SocialItem entry;

  @override
  State<SocialRow> createState() => _SocialRowState();
}

class _SocialRowState extends State<SocialRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        TwTextStyles.of(context)
            .sectionTitleForContext(
              context: context,
              color: context.twColors.pageBodyText,
            )
            .color ??
        TwTextStyles.of(context)
            .bodyForContext(
              context: context,
              color: context.twColors.pageBodyText,
            )
            .color ??
        Theme.of(context).textTheme.bodyMedium?.color ??
        context.twColors.pageBodyText;
    final Color color = _isHovered
        ? textColor.withValues(alpha: 0.82)
        : textColor;

    final tokens = TwTextStyleTokens.forBrightness(
      Theme.of(context).brightness,
    );
    final baseStyle = TwTextStyles.of(context).bodyForContextless(
      color: color,
      textScale:
          MediaQuery.textScalerOf(context).scale(tokens.twBodyBaseFontSize) /
          tokens.twBodyBaseFontSize,
    );
    final h2 = TwTextStyles.of(context).h2From(baseStyle);
    final TextStyle cardTitleStyle = TwTextStyles.of(context).cardTitleFrom(h2);
    final TextStyle linkTextStyle = cardTitleStyle.copyWith(
      fontWeight: FontWeight.w300,
      fontSize: cardTitleStyle.fontSize != null
          ? cardTitleStyle.fontSize! - 3.5
          : null,
    );

    final Widget row = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Semantics(
        button: true,
        label: widget.entry.label,
        child: Material(
          color: context.twColors.transparent,
          child: InkWell(
            hoverColor: textColor.withValues(alpha: 0.07),
            mouseCursor: SystemMouseCursors.click,
            onTap: widget.entry.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
              child: Row(
                children: <Widget>[
                  // Reserve a fixed icon slot so all labels start at the same x-position.
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: Center(
                      // Use IconTheme so both Material Icon and FaIcon inherit size/color.
                      child: IconTheme(
                        data: IconThemeData(size: 25, color: color),
                        child: widget.entry.icon,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: widget.entry.label),
                        if (widget.entry.copyUrl != null)
                          TextSpan(
                            text: ' (${widget.entry.copyUrl})',
                            style: TwTextStyles.of(
                              context,
                            ).transparentSelectionSpacer,
                          ),
                      ],
                    ),
                    style: linkTextStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final String? tooltip = widget.entry.copyUrl;
    if (tooltip == null || tooltip.isEmpty) {
      return row;
    }
    return Tooltip(message: tooltip, child: row);
  }
}

class SocialItem {
  const SocialItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.copyUrl,
  });

  final Widget icon;
  final String label;
  final String? copyUrl;
  final VoidCallback onTap;
}

class GoldAccentDivider extends StatelessWidget {
  const GoldAccentDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.twColors;
    final Color dotColor = colors.capabilityCardBevelHighlight;
    final Color glowColor = colors.goldAccent;
    final Color lineColor = colors.goldAccentLine;

    return SizedBox(
      height: 12.0,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            height: 1.0,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  lineColor.withValues(alpha: 0.0),
                  lineColor.withValues(alpha: 0.3),
                  lineColor,
                  lineColor.withValues(alpha: 0.3),
                  lineColor.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.28, 0.5, 0.65, 1.0],
              ),
            ),
          ),
          Container(
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                // Inner warm glow (higher intensity)
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.95),
                  blurRadius: 8.0,
                  spreadRadius: 2.0,
                ),
                // Outer soft large-radius ambient halo (higher intensity)
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.65),
                  blurRadius: 36.0,
                  spreadRadius: 7.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SelectableCopyBreak extends StatelessWidget {
  const SelectableCopyBreak({
    super.key,
    required this.height,
    this.lineBreaks = 1,
  }) : padding = EdgeInsets.zero;

  final double height;
  final int lineBreaks;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final selectionRegistrar = SelectionContainer.maybeOf(context);
    if (selectionRegistrar == null) {
      return SizedBox(height: height);
    }

    return SizedBox(
      height: height,
      child: IgnorePointer(
        child: Padding(
          padding: padding,
          child: Align(
            alignment: Alignment.topLeft,
            child: RichText(
              text: TextSpan(
                text: '\n' * lineBreaks,
                style: TwTextStyles.of(context).transparentSelectionSpacer,
              ),
              selectionRegistrar: selectionRegistrar,
              selectionColor: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
