
import 'skin_shared.dart';
import 'package:tw_primitives/colors.dart' show TwColors;

final _light = TwColors.forTheme('light');

final ChatSkinData chatLightSkin = ChatSkinData(
  colors: ChatSkinColors(
    transparent: _light.transparent,
    bubbleText: _light.bubbleText,
    shellBackground: _light.shellBackground,
    shellOuterShadow: _light.shellOuterShadow,
    shellOuterBorder: _light.shellOuterBorder,
    shellDivider: _light.shellDivider,
    botBubbleFill: _light.botBubbleFill,
    botBubbleBorder: _light.botBubbleBorder,
    bubbleShadow: _light.bubbleShadow,
    bubbleCollapseButton: _light.bubbleCollapseButton,
    bubbleCollapseButtonIcon: _light.bubbleCollapseButtonIcon,
    composerFill: _light.composerFill,
    composerBorder: _light.composerBorder,
    composerCursor: _light.composerCursor,
    composerCornerAccent: _light.composerCornerAccent,
    composerSendIcon: _light.composerSendIcon,
    // text-field tokens
    textFieldSelection: _light.textFieldSelection,
    textFieldCaret: _light.textFieldCaret,
    textFieldHint: _light.textFieldHint,
    toolbarColor: _light.toolbarColor,
    bubbleFadeMaskOpaque: _light.bubbleFadeMaskOpaque,
    bubbleFadeMaskSoft: _light.bubbleFadeMaskSoft,
    markupLink: _light.markupLink,
    scrollbarThumb: _light.scrollbarThumb,
    scrollbarThumbInactive: _light.scrollbarThumbInactive,
    scrollbarTrack: _light.scrollbarTrack,
  ),
);
