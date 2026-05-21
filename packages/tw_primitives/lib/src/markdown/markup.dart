import 'markup_ast.dart';
import 'markup_parser.dart' as markup_parser;

export 'markup_ast.dart';
export 'markup_rendering.dart';

class MessageMarkup {
  const MessageMarkup._();

  static MarkupDocument parse(String raw) {
    return markup_parser.MarkupParser(raw).parse();
  }

  static String toPlainText(String raw) {
    return parse(raw).toPlainText();
  }
}
