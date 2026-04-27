import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TmpPage extends StatefulWidget {
  const TmpPage({super.key});

  @override
  State<TmpPage> createState() => _TmpPageState();
}

class _TmpPageState extends State<TmpPage> {
  @override
  void initState() {
    super.initState();
    // Option 3: force a mobile platform so Flutter uses touch-style selection
    // and context-menu behaviour on web instead of the desktop defaults.
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  }

  @override
  void dispose() {
    debugDefaultTargetPlatformOverride = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: TextField(
          // Option 1: let Flutter defer context-menu rendering to the adaptive
          // toolbar (which on web defers to the browser) and enable spellcheck.
          contextMenuBuilder: (context, editableTextState) =>
              AdaptiveTextSelectionToolbar.editableText(
                editableTextState: editableTextState,
              ),
          spellCheckConfiguration: const SpellCheckConfiguration(),
          maxLines: null,
          expands: true,
        ),
      ),
    );
  }
}
