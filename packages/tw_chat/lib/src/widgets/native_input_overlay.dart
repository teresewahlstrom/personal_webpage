/// Conditional export that selects the correct [NativeInputOverlay]
/// implementation at compile time.
///
/// • On Flutter Web (where `dart:js_interop` is available) the web
///   implementation is used: a transparent HTML `<textarea>` is overlaid on
///   the Flutter TextField to provide browser-native spell-check, autocorrect
///   and mobile copy/paste.
///
/// • On all other platforms the stub is used: [NativeInputOverlay] is a
///   simple pass-through that returns its [child] unchanged.
export 'native_input_overlay_stub.dart'
    if (dart.library.js_interop) 'native_input_overlay_web.dart';
