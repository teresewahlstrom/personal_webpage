import 'package:flutter/material.dart';

class KeyboardHeight {
  const KeyboardHeight._();

  static double of(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }
}
