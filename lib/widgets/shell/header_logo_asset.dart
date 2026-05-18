import 'dart:async';

import 'package:flutter/widgets.dart';

const String kHeaderLogoAssetPath = 'assets/images/logo.png';
const AssetImage kHeaderLogoImage = AssetImage(kHeaderLogoAssetPath);
const Duration _headerLogoPrecacheTimeout = Duration(seconds: 3);

Future<void> precacheHeaderLogoAsset() {
  final Completer<void> completer = Completer<void>();
  final ImageStream stream = kHeaderLogoImage.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;

  void complete() {
    stream.removeListener(listener);
    if (!completer.isCompleted) {
      completer.complete();
    }
  }

  listener = ImageStreamListener(
    (ImageInfo image, bool synchronousCall) {
      complete();
    },
    onError: (Object error, StackTrace? stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'personal_webpage',
          context: ErrorDescription('while precaching the header logo'),
        ),
      );
      complete();
    },
  );

  stream.addListener(listener);
  return completer.future.timeout(
    _headerLogoPrecacheTimeout,
    onTimeout: () {
      stream.removeListener(listener);
    },
  );
}
