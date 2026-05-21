import 'markup_model.dart';
import 'markup_parser.dart' as markup_parser;

export 'markup_model.dart';
export 'markup_parser.dart';
export 'markup_tokenizer.dart';

class MessageMarkup {
  const MessageMarkup._();

  static MarkupDocument parse(String raw) {
    return markup_parser.MarkupParser(raw).parse();
  }

  static String toPlainText(String raw) {
    return parse(raw).toPlainText();
  }
}
