import 'package:flutter/material.dart';
import 'package:tw_primitives/theme.dart';

import '../services/project_cards_loader.dart';
import '../widgets/capabilities_grid.dart';
import '../widgets/social_widgets.dart';

class LandingPage extends StatefulWidget {
  final ValueChanged<bool>? onContentReadyChanged;

  const LandingPage({super.key, this.onContentReadyChanged});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  static const bool _showCapabilitiesGrid = true;

  late Future<ProjectCardsContent> _projectCardsFuture;
  bool? _lastReportedContentReady;

  @override
  void initState() {
    super.initState();
    _projectCardsFuture = ProjectCardsMarkdownLoader.loadProjectCards();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProjectCardsContent>(
      future: _projectCardsFuture,
      builder: (BuildContext context, AsyncSnapshot<ProjectCardsContent> snapshot) {
        final bool isContentReady =
            snapshot.connectionState == ConnectionState.done;
        if (_lastReportedContentReady != isContentReady) {
          _lastReportedContentReady = isContentReady;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            widget.onContentReadyChanged?.call(isContentReady);
          });
        }

        Widget content;

        if (snapshot.hasError) {
          content = Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Failed to load professional stories.',
                    textAlign: TextAlign.center,
                    style: TwTextStyles.of(context).sectionTitleForContext(
                      context: context,
                      color: context.twColors.pageBodyText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: TwTextStyles.of(context).bodyForContext(
                      context: context,
                      color: context.twColors.pageBodyText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _projectCardsFuture =
                            ProjectCardsMarkdownLoader.loadProjectCards();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (!snapshot.hasData) {
          // Use stable placeholder height to prevent jump when viewport changes (keyboard show/hide)
          // Fallback to 400px instead of dynamic viewport calculation
          content = const SizedBox(height: 400.0);
        } else {
          final data = snapshot.data!;
          content = Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 11),
                    child: _HeroStatement(),
                  ),
                  if (_showCapabilitiesGrid) ...<Widget>[
                    const SizedBox(height: 30),
                    Builder(
                      builder: (BuildContext context) {
                        final double width = MediaQuery.sizeOf(context).width;
                        final bool isSmallScreen = width < 640;
                        final double horizontalPadding = isSmallScreen
                            ? 4.0
                            : 11.0;
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: CapabilitiesGrid(cards: data.cards),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }

        return DefaultTextStyle(
          style: TwTextStyles.of(context).bodyForContext(
            context: context,
            color: context.twColors.pageBodyText,
          ),
          child: content,
        );
      },
    );
  }
}

class _HeroStatement extends StatelessWidget {
  const _HeroStatement();

  static const String _content =
      "Terese turns complexity into things people can use: products, tools, workflows, models, and organizational capability. Her work sits between engineering depth, product logic, knowledge structure, and implementation, helping teams define what should be built, build what is needed, and make the reasoning reusable.";

  static ColorFilter _lerpToBackgroundFilter({
    required Color background,
    required double sourceWeight,
  }) {
    final double clampedSourceWeight = sourceWeight.clamp(0.0, 1.0);
    final double backgroundWeight = 1.0 - clampedSourceWeight;
    return ColorFilter.matrix(<double>[
      clampedSourceWeight,
      0,
      0,
      0,
      backgroundWeight * background.r * 255.0,
      0,
      clampedSourceWeight,
      0,
      0,
      backgroundWeight * background.g * 255.0,
      0,
      0,
      clampedSourceWeight,
      0,
      backgroundWeight * background.b * 255.0,
      0,
      0,
      0,
      1,
      0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle baseBody = TwTextStyles.of(
      context,
    ).bodyForContext(context: context, color: context.twColors.pageBodyText);
    final TextStyle h1Style = () {
      final style = TwTextStyles.of(context).h1From(baseBody);
      return style.copyWith(
        color: context.twColors.pageHeadingText,
        fontSize: style.fontSize != null ? style.fontSize! + 10 : null,
      );
    }();
    final TextStyle bioStyle = baseBody.copyWith(
      fontSize: baseBody.fontSize != null ? baseBody.fontSize! + 2.5 : 17.5,
      height: 1.45,
    );
    final double viewportWidth = MediaQuery.sizeOf(context).width;
    final bool isWide = viewportWidth >= 340;
    final bool isCompact = viewportWidth < 550;
    final Widget profilePic = AngledProfileFrame(
      imagePath: 'assets/profile_pic.jpg',
      width: isCompact ? 134.0 : 154.0,
      height: isCompact ? 156.0 : 180.0,
      angleTowardRight: true,
      showPulseLine: false,
    );

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SelectableCopyBreak(
            height: isCompact ? 2 : 6,
            lineBreaks: isCompact ? 1 : 2,
          ),
          Center(
            child: isWide
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      profilePic,
                      SizedBox(width: viewportWidth >= 450 ? 22 : 14),
                      const SocialCard(),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      profilePic,
                      SizedBox(height: isCompact ? 12 : 16),
                      const SocialCard(),
                    ],
                  ),
          ),
          SizedBox(height: isCompact ? 22 : 30),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Terese Wahlström',
                  style: h1Style,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 7),
                const GoldAccentDivider(),
                const SizedBox(height: 7),
                Text(_content, style: bioStyle, textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AngledProfileFrame extends StatelessWidget {
  const AngledProfileFrame({
    super.key,
    required this.imagePath,
    this.width = 154,
    this.height = 180,
    this.angleTowardRight = true,
    this.showPulseLine = false,
  });

  final String imagePath;
  final double width;
  final double height;
  final bool angleTowardRight;
  final bool showPulseLine;

  @override
  Widget build(BuildContext context) {
    final direction = angleTowardRight ? -1.0 : 1.0;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        // Adds perspective depth.
        ..setEntry(3, 2, 0.0012)
        // Tilts the framed portrait toward the contact details.
        ..rotateY(direction * 0.3),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Custom-painted instrument frame (includes soft cast shadows).
            const CustomPaint(painter: _InstrumentFramePainter()),

            // Actual portrait (set back inside the frame).
            Positioned(
              left: 17,
              top: 16,
              right: 17,
              bottom: 17,
              child: ClipPath(
                clipper: const _ChamferedPortraitClipper(cut: 8, radius: 1.5),
                child: ColorFiltered(
                  colorFilter: _HeroStatement._lerpToBackgroundFilter(
                    background: context.twColors.pageBackground,
                    sourceWeight: context.twColors.heroPortraitOpacity,
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.10, -0.06),
                  ),
                ),
              ),
            ),

            // Reflection & Vignette Shadow Overlays
            Positioned(
              left: 17,
              top: 16,
              right: 17,
              bottom: 17,
              child: IgnorePointer(
                child: ClipPath(
                  clipper: const _ChamferedPortraitClipper(cut: 8, radius: 1.5),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Linear reflection
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Color(0x22FFFFFF),
                              Color(0x00FFFFFF),
                              Color(0x15000000),
                            ],
                            stops: [0.0, 0.58, 1.0],
                          ),
                        ),
                      ),
                      // Radial vignette shadow to feel deeply inset
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.85,
                            colors: [
                              Color(0x00000000),
                              Color(0x0C000000),
                              Color(0x3B000000),
                            ],
                            stops: [0.0, 0.65, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (showPulseLine)
              Positioned(
                left: 17,
                right: 17,
                bottom: 28,
                child: ClipPath(
                  clipper: const _ChamferedPortraitClipper(cut: 8, radius: 1.5),
                  child: const _PulseLine(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Path _createRoundedChamferPath({
  required Size size,
  required double inset,
  required double cut,
  required double d,
}) {
  final double L = inset;
  final double R = size.width - inset;
  final double T = inset;
  final double B = size.height - inset;
  const double h = 0.70710678118; // sin(45)

  final path = Path();

  // Corner 0: (L + cut, T)
  path.moveTo(L + cut - d * h, T + d * h);
  path.quadraticBezierTo(L + cut, T, L + cut + d, T);

  // Line to Corner 1: (R - cut, T)
  path.lineTo(R - cut - d, T);
  path.quadraticBezierTo(R - cut, T, R - cut + d * h, T + d * h);

  // Line to Corner 2: (R, T + cut)
  path.lineTo(R - d * h, T + cut - d * h);
  path.quadraticBezierTo(R, T + cut, R, T + cut + d);

  // Line to Corner 3: (R, B - cut)
  path.lineTo(R, B - cut - d);
  path.quadraticBezierTo(R, B - cut, R - d * h, B - cut + d * h);

  // Line to Corner 4: (R - cut, B)
  path.lineTo(R - cut + d * h, B - d * h);
  path.quadraticBezierTo(R - cut, B, R - cut - d, B);

  // Line to Corner 5: (L + cut, B)
  path.lineTo(L + cut + d, B);
  path.quadraticBezierTo(L + cut, B, L + cut - d * h, B - d * h);

  // Line to Corner 6: (L, B - cut)
  path.lineTo(L + d * h, B - cut + d * h);
  path.quadraticBezierTo(L, B - cut, L, B - cut - d);

  // Line to Corner 7: (L, T + cut)
  path.lineTo(L, T + cut + d);
  path.quadraticBezierTo(L, T + cut, L + d * h, T + cut - d * h);

  path.close();
  return path;
}

class _InstrumentFramePainter extends CustomPainter {
  const _InstrumentFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final outerShell = _createRoundedChamferPath(
      size: size,
      inset: 1.5,
      cut: 13,
      d: 2.5,
    );

    final mainBand = _createRoundedChamferPath(
      size: size,
      inset: 5.0,
      cut: 11,
      d: 2.5,
    );

    final recessedChannel = _createRoundedChamferPath(
      size: size,
      inset: 10.0,
      cut: 9,
      d: 2.5,
    );

    final innerLip = _createRoundedChamferPath(
      size: size,
      inset: 14.0,
      cut: 7,
      d: 2.5,
    );

    _paintCastShadow(canvas, outerShell);
    _paintOuterShell(canvas, size, outerShell);
    _paintMainBand(canvas, size, mainBand);
    _paintRecessedChannel(canvas, size, recessedChannel);
    _paintInnerLip(canvas, size, innerLip);
  }

  void _paintCastShadow(Canvas canvas, Path path) {
    canvas.drawPath(
      path.shift(const Offset(-4, 7)),
      Paint()
        ..color = const Color(0x32614531)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
  }

  void _paintOuterShell(Canvas canvas, Size size, Path path) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF3E8D8),
            Color(0xFFD2B68E),
            Color(0xFFF8EFE2),
            Color(0xFFB68C61),
          ],
          stops: [0.0, 0.22, 0.48, 0.72, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  void _paintMainBand(Canvas canvas, Size size, Path path) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.0
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFF0D8B6),
            Color(0xFFD1AB7B),
            Color(0xFFB08258),
            Color(0xFF7C573D),
            Color(0xFFC79B69),
          ],
          stops: [0.0, 0.24, 0.48, 0.74, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  void _paintRecessedChannel(Canvas canvas, Size size, Path path) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.4
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF8B674C),
            Color(0xFF5D4332),
            Color(0xFF3C2C24),
            Color(0xFF6B4E3A),
          ],
          stops: [0.0, 0.32, 0.68, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  void _paintInnerLip(Canvas canvas, Size size, Path path) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFFFF4E2),
            Color(0xFFD0A774),
            Color(0xFF8A603F),
            Color(0xFFE5C394),
          ],
          stops: [0.0, 0.36, 0.70, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ChamferedPortraitClipper extends CustomClipper<Path> {
  const _ChamferedPortraitClipper({required this.cut, required this.radius});

  final double cut;
  final double radius;

  @override
  Path getClip(Size size) {
    return _createRoundedChamferPath(
      size: size,
      inset: 0.0,
      cut: cut,
      d: radius,
    );
  }

  @override
  bool shouldReclip(covariant _ChamferedPortraitClipper oldClipper) {
    return oldClipper.cut != cut || oldClipper.radius != radius;
  }
}

class _PulseLine extends StatelessWidget {
  const _PulseLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: CustomPaint(painter: _PulseLinePainter()),
    );
  }
}

class _PulseLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * 0.58;

    final path = Path()
      ..moveTo(0, y)
      ..lineTo(size.width * 0.34, y)
      ..lineTo(size.width * 0.41, y - 5)
      ..lineTo(size.width * 0.46, y + 5)
      ..lineTo(size.width * 0.50, y - 18)
      ..lineTo(size.width * 0.54, y + 18)
      ..lineTo(size.width * 0.59, y - 7)
      ..lineTo(size.width * 0.65, y)
      ..lineTo(size.width, y);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0x66D99A38)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: [
          Color(0x00F1BA59),
          Color(0xFFFFF6DF),
          Color(0xFFF2A93C),
          Color(0xFFFFF6DF),
          Color(0x00F1BA59),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
