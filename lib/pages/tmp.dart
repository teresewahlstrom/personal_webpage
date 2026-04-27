import 'package:flutter/material.dart';

class TmpPage extends StatelessWidget {
  const TmpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: TextField(
          autofocus: true,
          maxLines: null,
          expands: true,
          decoration: null,
        ),
      ),
    );
  }
}
