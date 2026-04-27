import 'package:flutter/material.dart';

class TmpPage extends StatelessWidget {
  const TmpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Use a fresh ThemeData so no styling leaks in from the parent app.
      // platform: android forces touch-style selection / context-menu on web.
      theme: ThemeData(platform: TargetPlatform.android),
      home: Scaffold(
        body: TextField(
          // Defer context-menu rendering to the adaptive toolbar (which on
          // web defers to the browser) and enable spellcheck.
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
