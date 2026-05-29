import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/app_ui_config.dart';
import 'header_logo_asset.dart';

class PageHeader extends StatefulWidget {
  const PageHeader({super.key, this.logoAssetPath = kHeaderLogoAssetPath});

  final String logoAssetPath;

  @override
  State<PageHeader> createState() => _PageHeaderState();
}

class _PageHeaderState extends State<PageHeader> {
  bool get _isSvgLogo => widget.logoAssetPath.toLowerCase().endsWith('.svg');
  bool get _usesTextColorTint =>
      widget.logoAssetPath.toLowerCase().endsWith('assets/t1_logo/t1_logo.svg');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isSvgLogo) {
      precacheImage(AssetImage(widget.logoAssetPath), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final Color? logoColor = _usesTextColorTint
        ? PagePalette.bodyFor(brightness)
        : null;
    final AppLineStyle headerLine = ShellUiConfig.headerBorderFor(brightness);
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
          color: ShellUiConfig.headerBackgroundFor(brightness),
          border: Border(bottom: headerLine.borderSide),
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
                  SizedBox(
                    width: ShellUiConfig.headerLogoWidth,
                    height: ShellUiConfig.headerLogoHeight,
                    child: _isSvgLogo
                        ? SvgPicture.asset(
                            widget.logoAssetPath,
                            fit: BoxFit.contain,
                            colorFilter: logoColor == null
                                ? null
                                : ColorFilter.mode(logoColor, BlendMode.srcIn),
                          )
                        : Image.asset(widget.logoAssetPath, fit: BoxFit.contain),
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
