import 'dart:async';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

const String kHeaderLogoAssetPath = 'assets/t1_logo/t1_logo_3.svg';
const Duration _headerLogoPrecacheTimeout = Duration(seconds: 3);

Future<void> precacheHeaderLogoAsset() {
  final Completer<void> completer = Completer<void>();
  Future<void> complete() async {
    if (!completer.isCompleted) {
      completer.complete();
    }
  }

  rootBundle.loadString(kHeaderLogoAssetPath).then((_) {
    complete();
  }).catchError((Object error, StackTrace stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'personal_webpage',
          context: ErrorDescription('while precaching the header logo'),
        ),
      );
      complete();
    });

  return completer.future.timeout(
    _headerLogoPrecacheTimeout,
    onTimeout: () {},
  );
}
