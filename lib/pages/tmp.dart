import 'package:flutter/material.dart';

class TmpPage extends StatefulWidget {
  const TmpPage({super.key});

  @override
  State<TmpPage> createState() => _TmpPageState();
}

class _TmpPageState extends State<TmpPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }
}
