import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'keyword_composition_model.dart';

/// A single word after spiral placement, ready for rendering.
final class _PlacedWord {
  final KeywordNode node;
  final double left;
  final double top;
  final double fontSize;

  const _PlacedWord({
    required this.node,
    required this.left,
    required this.top,
    required this.fontSize,
  });
}

final class _WordBox {
  final KeywordNode node;
  final double left;
  final double top;
  final double width;
  final double height;
  final double fontSize;

  const _WordBox({
    required this.node,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.fontSize,
  });
}

final class _MeasuredKeyword {
  final KeywordNode node;
  final double fontSize;
  final Size size;

  const _MeasuredKeyword({
    required this.node,
    required this.fontSize,
    required this.size,
  });
}

final class _PlacementUnit {
  final List<_WordBox> words;
  final double width;
  final double height;
  final double priority;

  const _PlacementUnit({
    required this.words,
    required this.width,
    required this.height,
    required this.priority,
  });
}

/// Free-placement spiral word cloud.
///
/// Words are placed largest-first from the centre outward using an
/// Archimedean spiral (`r = a × θ`) and AABB collision detection.
/// No pill backgrounds — plain coloured text only, matching an editorial look.
class WordCloud extends StatelessWidget {
  final List<KeywordNode> keywords;

  /// Container height = width × [heightRatio].
  /// Use a smaller value (~0.50) for wide desktop layouts,
  /// larger (~0.80) for narrow mobile.
  final double heightRatio;

  final String fontFamily;
  final double letterSpacing;
  final double? maxContentWidth;

  const WordCloud({
    super.key,
    required this.keywords,
    this.heightRatio = 0.52,
    this.fontFamily = 'BebasNeue',
    this.letterSpacing = 1.5,
    this.maxContentWidth,
  });

  // ── Width resolution ──────────────────────────────────────────────────────

  double _resolveWidth(BuildContext context, BoxConstraints constraints) {
    double w = constraints.maxWidth.isFinite && constraints.maxWidth > 0
        ? constraints.maxWidth
        : MediaQuery.sizeOf(context).width;
    final double? cap = maxContentWidth;
    if (cap != null && cap > 0 && w > cap) w = cap;
    return w.clamp(200.0, double.infinity);
  }

  // ── Text measurement ──────────────────────────────────────────────────────

  Size _measureText(String text, FontWeight weight, double fontSize) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          fontWeight: weight,
          height: 1.0,
          letterSpacing: letterSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.size;
  }

  List<_MeasuredKeyword> _measureKeywords(List<KeywordNode> words, double w) {
    return words.map((KeywordNode word) {
      final double fontSize = w * word.em;
      final Size size = _measureText(word.text, word.weight, fontSize);
      return _MeasuredKeyword(node: word, fontSize: fontSize, size: size);
    }).toList(growable: false);
  }

  _PlacementUnit _singleUnit(KeywordNode word, double w) {
    final _MeasuredKeyword measured = _measureKeywords(<KeywordNode>[word], w).first;
    return _PlacementUnit(
      words: <_WordBox>[
        _WordBox(
          node: word,
          left: 0,
          top: 0,
          width: measured.size.width,
          height: measured.size.height,
          fontSize: measured.fontSize,
        ),
      ],
      width: measured.size.width,
      height: measured.size.height,
      priority: word.em,
    );
  }

  _PlacementUnit _groupUnit(List<KeywordNode> words, double w) {
    final List<KeywordNode> sorted = List<KeywordNode>.from(words)
      ..sort((KeywordNode a, KeywordNode b) {
        final int ao = a.lockOrder ?? 9999;
        final int bo = b.lockOrder ?? 9999;
        if (ao != bo) return ao.compareTo(bo);
        return b.em.compareTo(a.em);
      });

    final List<_MeasuredKeyword> measured = _measureKeywords(sorted, w);
    final String axis = sorted
            .map((KeywordNode word) => word.lockAxis)
            .firstWhere((String? value) => value != null, orElse: () => null) ??
        'vertical';
    final String lockAlign = sorted
        .map((KeywordNode word) => word.lockAlign)
        .firstWhere((String? value) => value != null, orElse: () => null) ??
      'left';
    final double? lockGapEm = sorted
        .map((KeywordNode word) => word.lockGapEm)
        .firstWhere((double? value) => value != null, orElse: () => null);

    final double maxFontSize = measured.fold(
      0.0,
      (double acc, _MeasuredKeyword item) => item.fontSize > acc ? item.fontSize : acc,
    );
    final double gap = lockGapEm != null ? lockGapEm * w : maxFontSize * 0.10;

    if (axis == 'horizontal') {
      double x = 0;
      double maxHeight = 0;
      final List<_WordBox> boxes = <_WordBox>[];
      for (int i = 0; i < measured.length; i++) {
        final _MeasuredKeyword item = measured[i];
        boxes.add(
          _WordBox(
            node: item.node,
            left: x,
            top: 0,
            width: item.size.width,
            height: item.size.height,
            fontSize: item.fontSize,
          ),
        );
        x += item.size.width;
        if (i != measured.length - 1) {
          x += gap;
        }
        if (item.size.height > maxHeight) {
          maxHeight = item.size.height;
        }
      }

      return _PlacementUnit(
        words: boxes,
        width: x,
        height: maxHeight,
        priority: sorted.fold(0.0, (double a, KeywordNode b) => a + b.em),
      );
    }

    // Vertical is default and best for editorial top/bottom pairings.
    final double maxWidth = measured.fold(
      0.0,
      (double acc, _MeasuredKeyword item) => item.size.width > acc ? item.size.width : acc,
    );
    double y = 0;
    final List<_WordBox> boxes = <_WordBox>[];
    for (int i = 0; i < measured.length; i++) {
      final _MeasuredKeyword item = measured[i];
      final String normalizedAlign = lockAlign.toLowerCase();
      final double left = switch (normalizedAlign) {
        'right' => maxWidth - item.size.width,
        'center' => (maxWidth - item.size.width) * 0.5,
        _ => 0,
      };
      boxes.add(
        _WordBox(
          node: item.node,
          left: left,
          top: y,
          width: item.size.width,
          height: item.size.height,
          fontSize: item.fontSize,
        ),
      );
      y += item.size.height;
      if (i != measured.length - 1) {
        y += gap;
      }
    }

    return _PlacementUnit(
      words: boxes,
      width: maxWidth,
      height: y,
      priority: sorted.fold(0.0, (double a, KeywordNode b) => a + b.em),
    );
  }

  List<_PlacementUnit> _buildPlacementUnits(List<KeywordNode> keywords, double w) {
    final List<KeywordNode> singles = <KeywordNode>[];
    final Map<String, List<KeywordNode>> grouped = <String, List<KeywordNode>>{};

    for (final KeywordNode kw in keywords) {
      final String? lockGroup = kw.lockGroup;
      if (lockGroup == null || lockGroup.isEmpty) {
        singles.add(kw);
        continue;
      }
      grouped.putIfAbsent(lockGroup, () => <KeywordNode>[]).add(kw);
    }

    final List<_PlacementUnit> units = <_PlacementUnit>[];
    for (final KeywordNode single in singles) {
      units.add(_singleUnit(single, w));
    }

    for (final List<KeywordNode> words in grouped.values) {
      if (words.length < 2) {
        units.add(_singleUnit(words.first, w));
        continue;
      }
      units.add(_groupUnit(words, w));
    }

    units.sort((_PlacementUnit a, _PlacementUnit b) => b.priority.compareTo(a.priority));
    return units;
  }

  // ── Spiral placement ──────────────────────────────────────────────────────

  List<_PlacedWord> _computeLayout(
    List<KeywordNode> keywords,
    double w,
    double h,
  ) {
    final List<_PlacementUnit> units = _buildPlacementUnits(keywords, w);

    final double cx = w * 0.5;
    final double cy = h * 0.5;

    // Gap added around every word's bounding box before overlap testing.
    const double pad = 9.0;

    // Archimedean spiral: r = a × θ.
    // a controls how quickly the spiral expands (pixels per radian).
    // A larger a = more open spiral, fewer iterations per revolution.
    const double a = 5.5;

    // Compress spiral vertically to match landscape containers.
    final double vRatio = (h / w).clamp(0.35, 1.0);

    // Per-step θ increment.  Fine enough to not skip narrow gaps for
    // typical word sizes (actual position delta ≈ a·Δθ for small r).
    const double thetaStep = 0.05;
    const int maxSteps = 3000;
    final double edgeInset = (w * 0.018).clamp(8.0, 16.0);

    final List<Rect> occupiedPadded = <Rect>[];
    final List<_PlacedWord> result = <_PlacedWord>[];

    for (final _PlacementUnit unit in units) {
      final double tw = unit.width;
      final double th = unit.height;

      for (int step = 0; step < maxSteps; step++) {
        final double theta = step * thetaStep;
        final double r = a * theta;
        final double x = cx + r * math.cos(theta) - tw * 0.5;
        final double y = cy + r * math.sin(theta) * vRatio - th * 0.5;

        // Keep words fully inside a safe inset so glyphs never get clipped
        // by the Stack viewport at the container edges.
        if (x < edgeInset || x + tw > w - edgeInset) continue;
        if (y < edgeInset || y + th > h - edgeInset) continue;

        final Rect candidate = Rect.fromLTWH(
          x - pad,
          y - pad,
          tw + pad * 2,
          th + pad * 2,
        );

        bool collides = false;
        for (final Rect other in occupiedPadded) {
          if (candidate.overlaps(other)) {
            collides = true;
            break;
          }
        }

        if (!collides) {
          occupiedPadded.add(candidate);
          for (final _WordBox word in unit.words) {
            result.add(_PlacedWord(
              node: word.node,
              left: x + word.left,
              top: y + word.top,
              fontSize: word.fontSize,
            ));
          }
          break;
        }
      }
      // Words that exceed maxSteps are silently dropped — the cloud is still
      // coherent without them, just less dense.
    }

    return result;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double w = _resolveWidth(context, constraints);
        final double h = w * heightRatio;
        final List<_PlacedWord> placed = _computeLayout(keywords, w, h);

        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              for (final _PlacedWord pw in placed)
                Positioned(
                  left: pw.left,
                  top: pw.top,
                  child: Text(
                    pw.node.text,
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: pw.fontSize,
                      fontWeight: pw.node.weight,
                      color: pw.node.color,
                      height: 1.0,
                      letterSpacing: letterSpacing,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
