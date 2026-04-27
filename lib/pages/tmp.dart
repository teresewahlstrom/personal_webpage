import 'package:flutter/material.dart';

/// Temporary bare-bones test page for diagnosing TextField selection handle
/// behavior on iOS mobile web.  No PageScaffold, no overlays — just a plain
/// Scaffold with a large centered TextField.
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
      appBar: AppBar(
        title: const Text('Tmp test'),
      ),
      body: Center(
        child: SizedBox(
          width: 400,
          child: TextField(
            controller: _controller,
            autofocus: true,
            maxLines: null,
            minLines: 8,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Type here…',
            ),
          ),
        ),
      ),
    );
  }
}
