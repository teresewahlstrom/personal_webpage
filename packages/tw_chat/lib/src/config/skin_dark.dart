
import 'skin_shared.dart';
import 'package:tw_primitives/colors.dart' show TwColors;

final _dark = TwColors.forTheme('dark');

final ChatSkinData chatDarkSkin = ChatSkinData(
  colors: ChatSkinColors(
    transparent: _dark.transparent,
    bubbleText: _dark.bubbleText,
    shellBackground: _dark.shellBackground,
    shellOuterShadow: _dark.shellOuterShadow,
    shellOuterBorder: _dark.shellOuterBorder,
    shellDivider: _dark.shellDivider,
    botBubbleFill: _dark.botBubbleFill,
    botBubbleBorder: _dark.botBubbleBorder,
    bubbleShadow: _dark.bubbleShadow,
    bubbleCollapseButton: _dark.bubbleCollapseButton,
    bubbleCollapseButtonIcon: _dark.bubbleCollapseButtonIcon,
    composerFill: _dark.composerFill,
    composerBorder: _dark.composerBorder,
    composerCursor: _dark.composerCursor,
    composerCornerAccent: _dark.composerCornerAccent,
    composerSendIcon: _dark.composerSendIcon,
    // text-field tokens
    textFieldSelection: _dark.textFieldSelection,
    textFieldCaret: _dark.textFieldCaret,
    textFieldHint: _dark.textFieldHint,
    toolbarColor: _dark.toolbarColor,
    bubbleFadeMaskOpaque: _dark.bubbleFadeMaskOpaque,
    bubbleFadeMaskSoft: _dark.bubbleFadeMaskSoft,
    markupLink: _dark.markupLink,
    scrollbarThumb: _dark.scrollbarThumb,
    scrollbarThumbInactive: _dark.scrollbarThumbInactive,
    scrollbarTrack: _dark.scrollbarTrack,
  ),
);
