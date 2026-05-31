import 'package:flutter/material.dart';
import 'package:tw_chat/chat.dart' show ChatSkinMode;
import 'package:tw_primitives/svg.dart';
import 'package:tw_primitives/theme.dart';

import 'config/app_ui_config.dart';
import 'pages/landing_page.dart';
import 'widgets/shell/page_header.dart' show kHeaderLogoAssetPath;
import 'widgets/shell/page_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await precacheTwSvgAsset(kHeaderLogoAssetPath).catchError((
    Object error,
    StackTrace stackTrace,
  ) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'personal_webpage',
        context: ErrorDescription('while precaching the header logo'),
      ),
    );
  });
  runApp(const T1GridApp());
}

class T1GridApp extends StatefulWidget {
  const T1GridApp({super.key});

  @override
  State<T1GridApp> createState() => _T1GridAppState();
}

class _T1GridAppState extends State<T1GridApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isPageContentReady = false;

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

  void _setPageContentReady(bool value) {
    if (_isPageContentReady == value) {
      return;
    }
    setState(() {
      _isPageContentReady = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Terese W personal website",
      themeAnimationDuration: Duration.zero,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: ShellUiConfig.pageBackgroundFor(
          Brightness.light,
        ),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: TwColors.forBrightness(Brightness.light).seedColor,
        ),
        fontFamily: TwBodyTextStyle.fontFamily,
      ),
      darkTheme: ThemeData(
        useMaterial3: false,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: ShellUiConfig.pageBackgroundFor(
          Brightness.dark,
        ),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: TwColors.forBrightness(Brightness.dark).seedColor,
        ),
        fontFamily: TwBodyTextStyle.fontFamily,
      ),
      themeMode: _themeMode,
      home: PageScaffold(
        showThemeToggle: true,
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleThemeMode,
        isPageLoading: !_isPageContentReady,
        showFooter: true,
        initialChatSkinMode: _isDarkMode
            ? ChatSkinMode.dark
            : ChatSkinMode.light,
        child: LandingPage(onContentReadyChanged: _setPageContentReady),
      ),
    );
  }
}
