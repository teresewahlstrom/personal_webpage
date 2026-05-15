library tw_primitives_chat_api;

export 'package:attributed_text/attributed_text.dart' show AttributedText;
export 'package:super_text_layout/super_text_layout.dart' show CaretStyle;

export 'src/text_field/super_textfield/super_textfield.dart'
    show TwTextField, TwTextFieldPlatformConfiguration, HintBehavior;

export 'src/text_field/super_textfield/infrastructure/attributed_text_editing_controller.dart'
    show AttributedTextEditingController;

export 'src/text_field/super_textfield/styles.dart'
    show defaultTextFieldStyleBuilder;

export 'src/text_field/super_textfield/super_textfield_context.dart'
    show TwTextFieldContext;

export 'src/text_field/super_textfield/infrastructure/magnifier.dart'
    show MagnifyingGlass;

export 'src/text_field/super_textfield/infrastructure/text_scrollview.dart'
    show TextScrollView;

export 'src/text_field/infrastructure/flutter/scrollbar.dart'
    show RawScrollbarWithCustomPhysics, RawScrollbarWithCustomPhysicsState, ScrollbarPainter;
