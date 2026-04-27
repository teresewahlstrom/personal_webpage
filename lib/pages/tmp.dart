import 'package:flutter/material.dart';

class TmpPage extends StatelessWidget {
  const TmpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Theme(
          // Option 3: force Android platform locally so Flutter uses
          // touch-style selection and context-menu behaviour on web.
          data: Theme.of(context).copyWith(platform: TargetPlatform.android),
          child: TextField(
            // Option 1: let Flutter defer context-menu rendering to the
            // adaptive toolbar (which on web defers to the browser) and
            // enable spellcheck.
            contextMenuBuilder: (context, editableTextState) =>
                AdaptiveTextSelectionToolbar.editableText(
                  editableTextState: editableTextState,
                ),
            spellCheckConfiguration: const SpellCheckConfiguration(),
            maxLines: null,
            expands: true,
          ),
        ),
      ),
    );
  }
}
