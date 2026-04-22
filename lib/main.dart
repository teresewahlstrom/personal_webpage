import 'package:flutter/material.dart';
import 'package:tw_chat/chat.dart' show ChatSkinMode;

import 'config/app_ui_config.dart';
import 'pages/landing_page.dart';
import 'widgets/shell/page_scaffold.dart';

void main() {
  runApp(const T1GridApp());
}

class T1GridApp extends StatefulWidget {
  const T1GridApp({super.key});

  @override
  State<T1GridApp> createState() => _T1GridAppState();
}

class _T1GridAppState extends State<T1GridApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLandingContentReady = false;

  bool get _isDarkMode {
    if (_themeMode == ThemeMode.dark) {
      return true;
    }
    if (_themeMode == ThemeMode.light) {
      return false;
    }
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  void _toggleThemeMode() {
    setState(() {
      _themeMode = _isDarkMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _setLandingContentReady(bool value) {
    if (_isLandingContentReady == value) {
      return;
    }
    setState(() {
      _isLandingContentReady = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "T1 grid",
      themeAnimationDuration: Duration.zero,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: ShellUiConfig.pageBackgroundFor(
          Brightness.light,
        ),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: AppColorTheme.appSeedFor(Brightness.light),
        ),
        fontFamily: "Inter18pt",
      ),
      darkTheme: ThemeData(
        useMaterial3: false,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ShellUiConfig.pageBackgroundFor(
          Brightness.dark,
        ),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: AppColorTheme.appSeedFor(Brightness.dark),
        ),
        fontFamily: "Inter18pt",
      ),
      themeMode: _themeMode,
      home: PageScaffold(
        showThemeToggle: true,
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleThemeMode,
        showFooter: _isLandingContentReady,
        initialChatSkinMode: _isDarkMode
            ? ChatSkinMode.dark
            : ChatSkinMode.light,
        child: LandingPage(onContentReadyChanged: _setLandingContentReady),
      ),
    );
  }
}
