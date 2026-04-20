import 'package:flutter/material.dart';

import 'pages/landing_page.dart';
import 'widgets/shell/page_scaffold.dart';

void main() {
  runApp(const T1GridApp());
}

class T1GridApp extends StatelessWidget {
  const T1GridApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "T1 grid",
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFFF8F9F7),
        fontFamily: "Inter18pt",
      ),
      home: const PageScaffold(
        child: LandingPage(),
      ),
    );
  }
}
