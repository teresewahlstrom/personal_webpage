import 'package:flutter/material.dart';
import 'package:tw_primitives/theme.dart';
import 'package:tw_primitives/svg.dart';

import '../../config/app_ui_config.dart';

const String kHeaderLogoAssetPath = 'assets/t1_logo/t1_logo.svg';

class PageHeader extends StatefulWidget {
  const PageHeader({super.key, this.logoAssetPath = kHeaderLogoAssetPath});

  final String logoAssetPath;

  @override
  State<PageHeader> createState() => _PageHeaderState();
}

class _PageHeaderState extends State<PageHeader> {
  bool get _isSvgLogo => widget.logoAssetPath.toLowerCase().endsWith('.svg');
  bool get _usesTextColorTint =>
      widget.logoAssetPath.toLowerCase().startsWith('assets/t1_logo/');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isSvgLogo) {
      precacheImage(AssetImage(widget.logoAssetPath), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color? logoColor =
        _usesTextColorTint ? context.twColors.headerLogoTint : null;
    final EdgeInsets safeInsets = MediaQuery.viewPaddingOf(context);
    final EdgeInsets contentPadding = EdgeInsets.fromLTRB(
      ShellUiConfig.headerPadding.left + safeInsets.left,
      ShellUiConfig.headerPadding.top + safeInsets.top,
      ShellUiConfig.headerPadding.right + safeInsets.right,
      ShellUiConfig.headerPadding.bottom,
    );
    return SizedBox(
      width: double.infinity,
      height: ShellUiConfig.headerMinHeight + safeInsets.top,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.twColors.transparent,
        ),
        child: Padding(
          padding: contentPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ShellUiConfig.headerMaxWidth,
              ),
              child: Row(
                children: <Widget>[
                  Opacity(
                    opacity: context.twIsDark ? 0.62 : 0.54,
                    child: SizedBox(
                      width: ShellUiConfig.headerLogoWidth,
                      height: ShellUiConfig.headerLogoHeight,
                      child: _isSvgLogo
                          ? TwSvgAsset(
                              widget.logoAssetPath,
                              fit: BoxFit.contain,
                              color: logoColor,
                            )
                          : Image.asset(
                              widget.logoAssetPath,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}