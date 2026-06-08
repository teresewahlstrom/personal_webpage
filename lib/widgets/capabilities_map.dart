import 'package:flutter/material.dart';
import 'package:tw_primitives/markdown.dart';
import 'package:tw_primitives/theme.dart';
import '../modals/project_story_modal.dart';
import 'app_modal.dart';
import 'shell/page_scaffold.dart';

class ProjectCardData {
  const ProjectCardData({required this.title, required this.contentDocument});

  final String title;
  final MarkupDocument contentDocument;
}

class _MapNode {
  final String id;
  final String title;
  final String label;
  final IconData icon;
  final double rx;
  final double ry;
  final List<String> connections;
  final bool isSubcategory;

  const _MapNode({
    required this.id,
    required this.title,
    required this.label,
    required this.icon,
    required this.rx,
    required this.ry,
    required this.connections,
    this.isSubcategory = false,
  });

  double getRx(bool isCompact) {
    if (id == 'architect') return 0.50;
    if (id == 'leader') return 0.50;
    if (id == 'computational') return isCompact ? 0.24 : 0.23;
    if (id == 'rd') return isCompact ? 0.70 : 0.71;
    if (id == 'physical' || id == 'digital' || id == 'services') {
      return isCompact ? 0.84 : 0.86;
    }
    if (id == 'metal') return isCompact ? 0.27 : 0.28;
    if (id == 'ai') return isCompact ? 0.68 : 0.70;
    return rx;
  }

  double getRy(bool isCompact) {
    return ry;
  }
}

class _MapEdge {
  final String from;
  final String to;
  const _MapEdge(this.from, this.to);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _MapEdge &&
          ((from == other.from && to == other.to) ||
              (from == other.to && to == other.from));

  @override
  int get hashCode => from.hashCode ^ to.hashCode;
}

class CapabilitiesMap extends StatefulWidget {
  const CapabilitiesMap({super.key, required this.cards});

  final List<ProjectCardData> cards;

  @override
  State<CapabilitiesMap> createState() => _CapabilitiesMapState();
}

class _CapabilitiesMapState extends State<CapabilitiesMap> {
  String? _hoveredNodeId;

  static const List<_MapNode> _nodes = <_MapNode>[
    _MapNode(
      id: 'architect',
      title: 'Capability Architect',
      label: 'Capability\nArchitect',
      icon: Icons.interests_outlined,
      rx: 0.50,
      ry: 0.50,
      connections: <String>['leader', 'computational', 'metal', 'ai', 'rd'],
    ),
    _MapNode(
      id: 'leader',
      title: 'Cross-Functional Leader',
      label: 'Cross-Functional\nLeader',
      icon: Icons.schema_outlined,
      rx: 0.50,
      ry: 0.11,
      connections: <String>['architect', 'rd'],
    ),
    _MapNode(
      id: 'computational',
      title: 'Computational Engineer',
      label: 'Computational\nEngineer',
      icon: Icons.terminal_outlined,
      rx: 0.23,
      ry: 0.37,
      connections: <String>['architect', 'ai', 'metal'],
    ),
    _MapNode(
      id: 'rd',
      title: 'Product R&D Engineer',
      label: 'Product R&D\nEngineer',
      icon: Icons.biotech_outlined,
      rx: 0.71,
      ry: 0.37,
      connections: <String>['architect', 'leader', 'metal', 'physical', 'digital', 'services'],
    ),
    _MapNode(
      id: 'metal',
      title: 'Metal 3D Printing Specialist',
      label: 'Metal 3D Printing\nSpecialist',
      icon: Icons.layers_outlined,
      rx: 0.28,
      ry: 0.82,
      connections: <String>['architect', 'computational', 'rd'],
    ),
    _MapNode(
      id: 'ai',
      title: 'AI Systems for Technical Work',
      label: 'AI Systems for\nTechnical Work',
      icon: Icons.memory_outlined,
      rx: 0.70,
      ry: 0.82,
      connections: <String>['architect', 'computational', 'digital'],
    ),
    // Subcategories
    _MapNode(
      id: 'physical',
      title: 'Product R&D Engineer',
      label: 'Physical',
      icon: Icons.inventory_2_outlined,
      rx: 0.86,
      ry: 0.21,
      connections: <String>['rd'],
      isSubcategory: true,
    ),
    _MapNode(
      id: 'digital',
      title: 'Product R&D Engineer',
      label: 'Digital',
      icon: Icons.computer_outlined,
      rx: 0.86,
      ry: 0.37,
      connections: <String>['rd', 'ai'],
      isSubcategory: true,
    ),
    _MapNode(
      id: 'services',
      title: 'Product R&D Engineer',
      label: 'Services',
      icon: Icons.cloud_outlined,
      rx: 0.86,
      ry: 0.53,
      connections: <String>['rd'],
      isSubcategory: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Map<String, ProjectCardData> cardsByTitle = {
      for (final card in widget.cards) card.title: card,
    };

    final Color lineColor = context.twIsDark
        ? context.twColors.lineSubtle
        : context.twColors.botBubbleBorder.withValues(alpha: 0.4);
    final Color activeColor = context.twColors.linkTextHover;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final bool isCompact = width < 550;
        final double height = width * (isCompact ? 0.88 : 0.76);

        return SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: _MapConnectionsPainter(
              nodes: _nodes,
              hoveredNodeId: _hoveredNodeId,
              lineColor: lineColor,
              activeColor: activeColor,
              isCompact: isCompact,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                for (final node in _nodes) () {
                  final double rx = node.getRx(isCompact);
                  final double ry = node.getRy(isCompact);
                  final double nodeWidth = node.isSubcategory
                      ? (isCompact ? 70.0 : 90.0)
                      : (isCompact ? 100.0 : 140.0);
                  final double circleSize = node.id == 'architect'
                      ? (isCompact ? 42.0 : 54.0)
                      : (node.isSubcategory
                          ? (isCompact ? 23.0 : 30.0)
                          : (isCompact ? 34.0 : 44.0));

                  final bool isHovered = _hoveredNodeId == node.id;
                  final bool isDimmed = _hoveredNodeId != null &&
                      _hoveredNodeId != node.id &&
                      !node.connections.contains(_hoveredNodeId);

                  final Widget nodeWidget = _MapNodeWidget(
                    node: node,
                    isHovered: isHovered,
                    isDimmed: isDimmed,
                    isCompact: isCompact,
                    onHover: (bool hovered) {
                      setState(() {
                        _hoveredNodeId = hovered ? node.id : null;
                      });
                    },
                    onTap: () {
                      final cardData = cardsByTitle[node.title];
                      if (cardData != null) {
                        PageScaffold.clearPageSelection(context);
                        showAppModal(
                          context: context,
                          headerTitle: cardData.title,
                          builder: (BuildContext context, VoidCallback close) {
                            return ProjectStoryModalContent(
                              contentDocument: cardData.contentDocument,
                            );
                          },
                        );
                      }
                    },
                  );

                  return Positioned(
                    left: rx * width - nodeWidth / 2,
                    top: ry * height - circleSize / 2,
                    child: node.isSubcategory
                        ? nodeWidget
                        : _PlainCopyHeadingRegistration(
                            heading: node.title,
                            child: nodeWidget,
                          ),
                  );
                }(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MapNodeWidget extends StatelessWidget {
  final _MapNode node;
  final bool isHovered;
  final bool isDimmed;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;
  final bool isCompact;

  const _MapNodeWidget({
    required this.node,
    required this.isHovered,
    required this.isDimmed,
    required this.onHover,
    required this.onTap,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArchitect = node.id == 'architect';
    final double circleSize = isArchitect
        ? (isCompact ? 42.0 : 54.0)
        : (node.isSubcategory
            ? (isCompact ? 23.0 : 30.0)
            : (isCompact ? 34.0 : 44.0));
    final double iconSize = isArchitect
        ? (isCompact ? 19.0 : 24.0)
        : (node.isSubcategory
            ? (isCompact ? 11.0 : 14.0)
            : (isCompact ? 16.0 : 20.0));
    final double fontSize = isArchitect
        ? (isCompact ? 12.5 : 15.0)
        : (node.isSubcategory
            ? (isCompact ? 10.0 : 12.0)
            : (isCompact ? 11.5 : 13.5));

    final Color activeColor = context.twColors.linkTextHover;
    final Color textColor = isDimmed
        ? context.twColors.pageBodyText.withValues(alpha: 0.3)
        : context.twColors.pageBodyText.withValues(
            alpha: node.isSubcategory ? 0.72 : 1.0,
          );

    final Color circleBorderColor = isHovered
        ? activeColor
        : (isDimmed
            ? context.twColors.botBubbleBorder.withValues(alpha: 0.2)
            : context.twColors.botBubbleBorder.withValues(
                alpha: isArchitect ? 0.85 : (node.isSubcategory ? 0.34 : 0.6),
              ));

    // Transparent background by default, translucent active color on hover
    final Color circleBg = isHovered
        ? activeColor.withValues(alpha: 0.15)
        : (isArchitect
            ? context.twColors.pageBackground.withValues(alpha: 0.42)
            : context.twColors.pageBackground.withValues(
                alpha: node.isSubcategory ? 0.18 : 0.28,
              ));

    final Color iconColor = isHovered
        ? activeColor
        : (isDimmed
            ? context.twColors.pageBodyText.withValues(alpha: 0.35)
            : context.twColors.pageBodyText.withValues(
                alpha: node.isSubcategory ? 0.58 : 0.85,
              ));

    final List<Shadow> textShadows = <Shadow>[
      // Halo masking shadows in the theme background color to cover intersecting connection lines
      Shadow(color: context.twColors.pageBackground, offset: const Offset(-1.5, -1.5), blurRadius: 1.0),
      Shadow(color: context.twColors.pageBackground, offset: const Offset(1.5, -1.5), blurRadius: 1.0),
      Shadow(color: context.twColors.pageBackground, offset: const Offset(-1.5, 1.5), blurRadius: 1.0),
      Shadow(color: context.twColors.pageBackground, offset: const Offset(1.5, 1.5), blurRadius: 1.0),
      Shadow(color: context.twColors.pageBackground, offset: const Offset(-1.5, 0), blurRadius: 1.0),
      Shadow(color: context.twColors.pageBackground, offset: const Offset(1.5, 0), blurRadius: 1.0),
      Shadow(color: context.twColors.pageBackground, offset: const Offset(0, -1.5), blurRadius: 1.0),
      Shadow(color: context.twColors.pageBackground, offset: const Offset(0, 1.5), blurRadius: 1.0),
      Shadow(color: context.twColors.pageBackground, offset: Offset.zero, blurRadius: 4.0),
      Shadow(color: context.twColors.pageBackground, offset: Offset.zero, blurRadius: 6.0),
      // Theme drop shadows for depth
      ...context.twTextStyleTokens.twCardTitleShadows,
    ];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleBg,
                border: Border.all(
                  color: circleBorderColor,
                  width: isHovered ? 1.5 : 1.0,
                ),
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.35),
                          blurRadius: isCompact ? 6.0 : 10.0,
                          spreadRadius: 1.0,
                        )
                      ]
                    : [
                        BoxShadow(
                          color: activeColor.withValues(
                            alpha: isArchitect ? 0.12 : 0.045,
                          ),
                          blurRadius: isArchitect ? 18.0 : 10.0,
                          spreadRadius: isArchitect ? 1.0 : 0.0,
                        ),
                      ],
              ),
              child: Center(
                child: TweenAnimationBuilder<Color?>(
                  duration: const Duration(milliseconds: 200),
                  tween: ColorTween(end: iconColor),
                  builder: (BuildContext context, Color? color, Widget? child) {
                    return Icon(
                      node.icon,
                      size: iconSize,
                      color: color,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: node.isSubcategory
                  ? (isCompact ? 70.0 : 90.0)
                  : (isCompact ? 100.0 : 140.0),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                textAlign: TextAlign.center,
                maxLines: node.isSubcategory ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: fontSize,
                  fontWeight: isArchitect
                      ? FontWeight.w400
                      : (isHovered ? FontWeight.w400 : FontWeight.w300),
                  color: textColor,
                  height: 1.25,
                  shadows: textShadows,
                ),
                child: Text(node.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapConnectionsPainter extends CustomPainter {
  final List<_MapNode> nodes;
  final String? hoveredNodeId;
  final Color lineColor;
  final Color activeColor;
  final bool isCompact;

  _MapConnectionsPainter({
    required this.nodes,
    required this.hoveredNodeId,
    required this.lineColor,
    required this.activeColor,
    required this.isCompact,
  });

  double _getCircleSize(_MapNode node, bool isCompact) {
    if (node.id == 'architect') {
      return isCompact ? 42.0 : 54.0;
    }
    return node.isSubcategory
        ? (isCompact ? 23.0 : 30.0)
        : (isCompact ? 34.0 : 44.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintAnchoringLayer(canvas, size);

    final edges = _getUniqueEdges();

    for (final edge in edges) {
      final fromNode = nodes.firstWhere((n) => n.id == edge.from);
      final toNode = nodes.firstWhere((n) => n.id == edge.to);

      final rx1 = fromNode.getRx(isCompact);
      final ry1 = fromNode.getRy(isCompact);
      final rx2 = toNode.getRx(isCompact);
      final ry2 = toNode.getRy(isCompact);

      final p1 = Offset(rx1 * size.width, ry1 * size.height);
      final p2 = Offset(rx2 * size.width, ry2 * size.height);

      // Shorten endpoints to stop at the edge of the node circles
      final double r1 = _getCircleSize(fromNode, isCompact) / 2;
      final double r2 = _getCircleSize(toNode, isCompact) / 2;
      final Offset direction = p2 - p1;
      final double distance = direction.distance;

      final Offset p1Shortened = distance > r1
          ? p1 + (direction * (r1 / distance))
          : p1;
      final Offset p2Shortened = distance > r2
          ? p2 - (direction * (r2 / distance))
          : p2;

      final isEdgeHighlighted = hoveredNodeId != null &&
          (edge.from == hoveredNodeId || edge.to == hoveredNodeId);
      final isAnyHovered = hoveredNodeId != null;

      final bool isArchitectEdge =
          edge.from == 'architect' || edge.to == 'architect';
      final bool isSupportingEdge =
          fromNode.isSubcategory || toNode.isSubcategory;
      final double opacity = isAnyHovered
          ? (isEdgeHighlighted ? 0.90 : 0.05)
          : (isArchitectEdge ? 0.38 : (isSupportingEdge ? 0.16 : 0.24));

      final paintColor = isEdgeHighlighted ? activeColor : lineColor;

      final mainPaint = Paint()
        ..color = paintColor.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isEdgeHighlighted 
            ? (isCompact ? 2.0 : 2.5)
            : (isArchitectEdge
                ? (isCompact ? 1.15 : 1.55)
                : (isCompact ? 0.75 : 1.15))
        ..strokeCap = StrokeCap.round;

      final path = Path();
      path.moveTo(p1Shortened.dx, p1Shortened.dy);

      if (fromNode.isSubcategory || toNode.isSubcategory) {
        final dx = (p2Shortened.dx - p1Shortened.dx).abs();
        path.cubicTo(
          p1Shortened.dx + dx * 0.5, p1Shortened.dy,
          p2Shortened.dx - dx * 0.5, p2Shortened.dy,
          p2Shortened.dx, p2Shortened.dy,
        );
      } else {
        final mx = (p1Shortened.dx + p2Shortened.dx) / 2;
        final my = (p1Shortened.dy + p2Shortened.dy) / 2;
        final cx = mx;
        final cy = my - (size.height * 0.03);
        path.quadraticBezierTo(cx, cy, p2Shortened.dx, p2Shortened.dy);
      }

      if (isEdgeHighlighted) {
        final glowPaint = Paint()
          ..color = activeColor.withValues(alpha: 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isCompact ? 6.0 : 8.5
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(path, glowPaint);

        final glowPaintInner = Paint()
          ..color = activeColor.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isCompact ? 3.0 : 4.0
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(path, glowPaintInner);
      }

      canvas.drawPath(path, mainPaint);
    }
  }

  void _paintAnchoringLayer(Canvas canvas, Size size) {
    final Offset center = Offset(size.width * 0.50, size.height * 0.50);
    final Paint radialGlow = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          activeColor.withValues(alpha: 0.075),
          lineColor.withValues(alpha: 0.030),
          lineColor.withValues(alpha: 0.0),
        ],
        stops: const <double>[0.0, 0.44, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: size.shortestSide * (isCompact ? 0.42 : 0.38),
        ),
      );
    canvas.drawCircle(
      center,
      size.shortestSide * (isCompact ? 0.42 : 0.38),
      radialGlow,
    );

    final Paint guidePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isCompact ? 0.55 : 0.75
      ..strokeCap = StrokeCap.round;
    final Paint guideGlowPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isCompact ? 5.0 : 7.0
      ..strokeCap = StrokeCap.round;

    final List<Offset> guidePoints = <Offset>[
      Offset(size.width * 0.50, size.height * 0.11),
      Offset(size.width * 0.23, size.height * 0.37),
      Offset(size.width * 0.71, size.height * 0.37),
      Offset(size.width * 0.28, size.height * 0.82),
      Offset(size.width * 0.70, size.height * 0.82),
    ];

    for (final Offset point in guidePoints) {
      final Path path = Path()
        ..moveTo(center.dx, center.dy)
        ..quadraticBezierTo(
          (center.dx + point.dx) / 2,
          (center.dy + point.dy) / 2 - size.height * 0.018,
          point.dx,
          point.dy,
        );
      canvas.drawPath(path, guideGlowPaint);
      canvas.drawPath(path, guidePaint);
    }

    final Paint nodeAnchorPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;
    for (final _MapNode node in nodes) {
      final Offset nodeCenter = Offset(
        node.getRx(isCompact) * size.width,
        node.getRy(isCompact) * size.height,
      );
      canvas.drawCircle(
        nodeCenter,
        _getCircleSize(node, isCompact) * (node.isSubcategory ? 0.80 : 0.72),
        nodeAnchorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MapConnectionsPainter oldDelegate) {
    return oldDelegate.hoveredNodeId != hoveredNodeId ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.isCompact != isCompact;
  }

  Set<_MapEdge> _getUniqueEdges() {
    final Set<_MapEdge> edges = {};
    for (final node in nodes) {
      for (final targetId in node.connections) {
        edges.add(_MapEdge(node.id, targetId));
      }
    }
    return edges;
  }
}

class _PlainCopyHeadingRegistration extends StatefulWidget {
  const _PlainCopyHeadingRegistration({
    required this.heading,
    required this.child,
  });

  final String heading;
  final Widget child;

  @override
  State<_PlainCopyHeadingRegistration> createState() =>
      _PlainCopyHeadingRegistrationState();
}

class _PlainCopyHeadingRegistrationState
    extends State<_PlainCopyHeadingRegistration> {
  final Object _registrationKey = Object();
  MarkupSelectionRegistry? _registry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateRegistration();
  }

  @override
  void didUpdateWidget(covariant _PlainCopyHeadingRegistration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.heading != oldWidget.heading) {
      _updateRegistration();
    }
  }

  @override
  void dispose() {
    _registry?.copyHelper.unregisterPlainHeading(_registrationKey);
    super.dispose();
  }

  void _updateRegistration() {
    final MarkupSelectionRegistry? registry = MarkupSelectionRegistry.maybeOf(
      context,
    );
    if (registry != _registry) {
      _registry?.copyHelper.unregisterPlainHeading(_registrationKey);
      _registry = registry;
    }
    _registry?.copyHelper.registerPlainHeading(
      _registrationKey,
      widget.heading,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
