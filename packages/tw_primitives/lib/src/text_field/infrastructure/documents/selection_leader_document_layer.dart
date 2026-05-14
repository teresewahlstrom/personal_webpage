import 'dart:ui';

import 'package:follow_the_leader/follow_the_leader.dart';

/// Visual layout bounds related to a user selection in a document.
class DocumentSelectionLayout {
  const DocumentSelectionLayout({
    this.caret,
    this.upstream,
    this.downstream,
    this.expandedSelectionBounds,
  });

  final Rect? caret;
  final Rect? upstream;
  final Rect? downstream;
  final Rect? expandedSelectionBounds;
}

/// A minimal set of links used by mobile editing overlays.
class SelectionLayerLinks {
  SelectionLayerLinks({
    LeaderLink? caretLink,
    LeaderLink? upstreamLink,
    LeaderLink? downstreamLink,
    LeaderLink? expandedSelectionBoundsLink,
  })  : caretLink = caretLink ?? LeaderLink(),
        upstreamLink = upstreamLink ?? LeaderLink(),
        downstreamLink = downstreamLink ?? LeaderLink(),
        expandedSelectionBoundsLink = expandedSelectionBoundsLink ?? LeaderLink();

  final LeaderLink caretLink;
  final LeaderLink upstreamLink;
  final LeaderLink downstreamLink;
  final LeaderLink expandedSelectionBoundsLink;
}
