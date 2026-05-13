import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_super_editor/src/default_editor/document_ime/ime_decoration.dart';

void main() {
  test('TextInputConnectionDecorator forwards updateStyle to the wrapped connection', () {
    final connection = _RecordingTextInputConnection();
    final decorator = _TestTextInputConnectionDecorator(connection);

    decorator.updateStyle('style payload');

    expect(connection.lastUpdateStyleArgument, 'style payload');
  });
}

class _TestTextInputConnectionDecorator extends TextInputConnectionDecorator {
  _TestTextInputConnectionDecorator([super.client]);
}

class _RecordingTextInputConnection implements TextInputConnection {
  Object? lastUpdateStyleArgument;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #updateStyle) {
      lastUpdateStyleArgument = invocation.positionalArguments.single;
      return null;
    }

    return super.noSuchMethod(invocation);
  }
}
