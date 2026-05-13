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

  test('TextInputConnectionDecorator ignores missing updateStyle implementations', () {
    final decorator = _TestTextInputConnectionDecorator(_ThrowingTextInputConnection());

    expect(() => decorator.updateStyle('style payload'), returnsNormally);
  });
}

class _TestTextInputConnectionDecorator extends TextInputConnectionDecorator {
  _TestTextInputConnectionDecorator(TextInputConnection connection) : super(connection);
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

class _ThrowingTextInputConnection implements TextInputConnection {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
