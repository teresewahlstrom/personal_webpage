import 'markup_ast.dart';
import 'markup_parser.dart' as markup_parser;

export 'markup_ast.dart'
    show
        MarkupDocument,
        MarkupInline,
        MarkupBlock,
        MarkupParagraphBlock,
        MarkupHeadingBlock,
        MarkupBlockquoteBlock,
        MarkupListBlock,
        MarkupListItem;
export 'markup_rendering.dart'
    show
        LinkGestureRecognizerFactory,
        MarkupTheme,
        MarkupDocumentRendering,
        MarkupBlockRendering;

class MessageMarkup {
  const MessageMarkup._();

  static MarkupDocument parse(String raw) {
    return markup_parser.MarkupParser(raw).parse();
  }

  static String toPlainText(String raw) {
    return parse(raw).toPlainText();
  }
}
