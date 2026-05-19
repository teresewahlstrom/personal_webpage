import 'message_markup_model.dart';
import 'message_markup_parser.dart' as markup_parser;

export 'message_markup_model.dart';
export 'message_markup_parser.dart';
export 'message_markup_tokenizer.dart';

class ChatMessageMarkup {
  const ChatMessageMarkup._();

  static ChatMarkupDocument parse(String raw) {
    return markup_parser.ChatMarkupParser(raw).parse();
  }

  static String toPlainText(String raw) {
    return parse(raw).toPlainText();
  }
}
