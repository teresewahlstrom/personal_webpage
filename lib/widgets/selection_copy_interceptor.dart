import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SelectedContent;
import 'package:tw_primitives/markdown.dart'
    show MarkupSelectionCopyHelper, MarkupSelectionRegistry, TwWebCopyInterceptor;

typedef SelectionCopyInterceptorBuilder = Widget Function(
  BuildContext context,
  ValueChanged<SelectedContent?> onSelectionChanged,
);

class SelectionCopyInterceptor extends StatefulWidget {
  const SelectionCopyInterceptor({
    super.key,
    required this.builder,
    this.shouldInterceptCopy,
    this.onSelectionChanged,
  });

  final SelectionCopyInterceptorBuilder builder;
  final ValueGetter<bool>? shouldInterceptCopy;
  final ValueChanged<SelectedContent?>? onSelectionChanged;

  @override
  State<SelectionCopyInterceptor> createState() =>
      SelectionCopyInterceptorState();
}

class SelectionCopyInterceptorState extends State<SelectionCopyInterceptor> {
  final MarkupSelectionCopyHelper copyHelper = MarkupSelectionCopyHelper();
  late final TwWebCopyInterceptor _webCopyInterceptor;
  SelectedContent? lastSelectedContent;

  @override
  void initState() {
    super.initState();
    _webCopyInterceptor = TwWebCopyInterceptor(
      () {
        final globalPlainText = lastSelectedContent?.plainText ?? '';
        return copyHelper.resolveCopyText(globalPlainText: globalPlainText);
      },
      shouldInterceptCopy: () {
        final hasSelection =
            lastSelectedContent?.plainText.isNotEmpty ?? false;
        if (!hasSelection) {
          return false;
        }
        return widget.shouldInterceptCopy?.call() ?? true;
      },
    )..attach();
  }

  @override
  void dispose() {
    _webCopyInterceptor.detach();
    copyHelper.dispose();
    super.dispose();
  }

  void _handleSelectionChanged(SelectedContent? content) {
    // Intentionally avoiding setState() here because updating selection state
    // does not require rebuild of this widget wrapper. We only need the reference
    // updated for clipboard operations.
    lastSelectedContent = content;
    widget.onSelectionChanged?.call(content);
  }

  @override
  Widget build(BuildContext context) {
    return MarkupSelectionRegistry(
      copyHelper: copyHelper,
      child: widget.builder(context, _handleSelectionChanged),
    );
  }
}
