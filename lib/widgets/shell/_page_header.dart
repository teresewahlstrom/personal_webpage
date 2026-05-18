import 'package:flutter/material.dart';

import '../../config/app_ui_config.dart';

class PageHeader extends StatefulWidget {
  const PageHeader({
    super.key,
    this.logoAssetPath = 'assets/images/logo.png',
  });

  final String logoAssetPath;

  @override
  State<PageHeader> createState() => _PageHeaderState();
}

class _PageHeaderState extends State<PageHeader> {
  late final AssetImage _logoImage;

  @override
  void initState() {
    super.initState();
    _logoImage = AssetImage(widget.logoAssetPath);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(_logoImage, context);
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final AppLineStyle headerLine = ShellUiConfig.headerBorderFor(brightness);
    return SizedBox(
      width: double.infinity,
      height: ShellUiConfig.headerMinHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ShellUiConfig.headerBackgroundFor(brightness),
          border: Border(
            bottom: headerLine.borderSide,
          ),
        ),
        child: Padding(
          padding: ShellUiConfig.headerPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ShellUiConfig.headerMaxWidth,
              ),
              child: Row(
                children: <Widget>[
                  RepaintBoundary(
                    child: SizedBox(
                      width: ShellUiConfig.headerLogoWidth,
                      height: ShellUiConfig.headerLogoHeight,
                      child: Image(
                        image: _logoImage,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                        isAntiAlias: true,
                        filterQuality: FilterQuality.high,
                        frameBuilder: (
                          BuildContext context,
                          Widget child,
                          int? frame,
                          bool wasSynchronouslyLoaded,
                        ) {
                          if (wasSynchronouslyLoaded || frame != null) {
                            return child;
                          }
                          return const SizedBox.shrink();
                        },
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
