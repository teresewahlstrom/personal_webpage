import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

class TmpPage extends StatelessWidget {
  const TmpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SuperTextField(
          maxLines: null,
          hintBuilder: (context) => const Text(
            'Type something...',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
