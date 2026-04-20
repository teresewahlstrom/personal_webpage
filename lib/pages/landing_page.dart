import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tw_chat/chat.dart';
import 'package:tw_chat/content.dart';
import 'package:tw_keywords/tw_keywords.dart';
import 'package:url_launcher/url_launcher.dart';

import 'newsletter/newsletter_modal_content.dart';
import 'privacy_cookies_content.dart';
import '../data/subject_keywords_registry.dart';
import '../models/subject_keyword_data.dart';
import '../widgets/app_modal.dart';
import '../widgets/arrow_key_scroll_wrapper.dart';
import '../widgets/grid_background_with_chat.dart';

class LandingPage extends StatefulWidget {
  /// The subject to display (defaults to Terese)
  final SubjectKeywordData? subject;

  const LandingPage({
    super.key,
    this.subject,
  });

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isChatKeyboardScrollTarget = ValueNotifier<bool>(
    false,
  );
  late Future<SubjectKeywordData> _subjectFuture;
  late final TwinConversationController _conversationController;
  late final List<bool> _expandedTiles = List<bool>.filled(
    _skills.length,
    false,
    growable: false,
  );

  static const String _dummyReplyText =
      'This is a prototype reply from Twin chat. Real backend responses are not connected yet.';

  @override
  void initState() {
    super.initState();
    _subjectFuture = widget.subject != null
        ? Future<SubjectKeywordData>.value(widget.subject)
        : SubjectRegistry.defaultSubject();
    _conversationController = TwinConversationController(
      introText: twinPrototypeIntroText,
      replyClient: const FixedTwinReplyClient(
        replyText: _dummyReplyText,
        replyDelay: Duration(milliseconds: 450),
      ),
      ownsReplyClient: true,
    );
  }

  void _setChatKeyboardScrollTarget(bool value) {
    if (_isChatKeyboardScrollTarget.value == value) {
      return;
    }
    _isChatKeyboardScrollTarget.value = value;
  }

  @override
  void dispose() {
    _conversationController.dispose();
    _isChatKeyboardScrollTarget.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _allExpanded => _expandedTiles.every((bool expanded) => expanded);

  void _toggleAllTiles(bool value) {
    setState(() {
      _expandedTiles.fillRange(0, _expandedTiles.length, value);
    });
  }

  void _toggleTile(int index) {
    setState(() {
      _expandedTiles[index] = !_expandedTiles[index];
    });
  }

  Future<void> _launchUrl(String rawUrl) async {
    final Uri uri = Uri.parse(rawUrl);
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.platformDefault,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Could not open $rawUrl")));
    }
  }

  void _openNewsletterModal() {
    showAppModal(
      context: context,
      contentPadding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      builder: (BuildContext context, VoidCallback close) {
        return const NewsletterModalContent();
      },
    );
  }

  void _openPrivacyModal() {
    showAppModal(
      context: context,
      builder: (BuildContext context, VoidCallback close) {
        return PrivacyCookiesContent(onLaunchUrl: _launchUrl);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SubjectKeywordData>(
      future: _subjectFuture,
      builder: (BuildContext context, AsyncSnapshot<SubjectKeywordData> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Failed to load subject data: ${snapshot.error}'),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final SubjectKeywordData subject = snapshot.data!;
        final Size viewport = MediaQuery.sizeOf(context);
        // heightRatio: taller on mobile (portrait), shallower on wide desktop.
        final double cloudHeightRatio = viewport.width >= 900 ? 0.52 : 0.80;

        return DefaultTextStyle(
          style: _Styles.body,
          child: Scaffold(
            body: Stack(
              children: <Widget>[
                GridBackgroundWithChat(
                  child: ArrowKeyScrollWrapper(
                    controller: _scrollController,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 700),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 11),
                                      child: const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height: 8),
                                          _HeaderLogo(),
                                          SizedBox(height: 10),
                                          _HeroStatement(),
                                          SizedBox(height: 14),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 980),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 18),
                                      child: WordCloud(
                                        keywords: subject.keywords,
                                        heightRatio: cloudHeightRatio,
                                        maxContentWidth: 980,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 26),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 700),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 11),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          _SkillsSection(
                                            expandedTiles: _expandedTiles,
                                            onToggleAll: _toggleAllTiles,
                                            onToggleTile: _toggleTile,
                                            allExpanded: _allExpanded,
                                          ),
                                          const SizedBox(height: 24),
                                          _SocialSection(
                                            title: "Contact",
                                            entries: <_SocialItem>[
                                              _SocialItem(
                                                icon: const Icon(Icons.email_outlined),
                                                label: "terese@t1grid.com",
                                                onTap: () => _launchUrl(
                                                  "mailto:terese@t1grid.com",
                                                ),
                                              ),
                                              _SocialItem(
                                                icon: const Icon(Icons.phone_outlined),
                                                label: "+46 709 800 525",
                                                onTap: () => _launchUrl(
                                                  "tel:+46709800525",
                                                ),
                                              ),
                                              _SocialItem(
                                                icon: const Icon(
                                                  Icons.calendar_month_outlined,
                                                ),
                                                label: "Video meeting",
                                                onTap: () => _launchUrl(
                                                  "https://cal.com/teresew/intro",
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          _SocialSection(
                                            title: "Follow",
                                            entries: <_SocialItem>[
                                              _SocialItem(
                                                icon: const Icon(
                                                  Icons.notifications_active_outlined,
                                                ),
                                                label: "Newsletter",
                                                onTap: _openNewsletterModal,
                                              ),
                                              _SocialItem(
                                                icon: const FaIcon(
                                                  FontAwesomeIcons.linkedinIn,
                                                ),
                                                label: "LinkedIn",
                                                onTap: () => _launchUrl(
                                                  "https://www.linkedin.com/in/teresewahlstrom",
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 40),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _Footer(onOpenPrivacy: _openPrivacyModal),
                      ],
                    ),
                  ),
                ),
                // Twin chat overlay - positioned at Scaffold level for proper floating
                AnimatedBuilder(
                  animation: _conversationController,
                  builder: (BuildContext context, Widget? child) {
                    return TwinChatDock(
                      messages: _conversationController.messages,
                      onSend: _conversationController.sendMessage,
                      onStop: _conversationController.stopPendingReply,
                      isChatKeyboardScrollTarget: _isChatKeyboardScrollTarget,
                      onSetChatKeyboardScrollTarget: () =>
                          _setChatKeyboardScrollTarget(true),
                      onSetPageKeyboardScrollTarget: () =>
                          _setChatKeyboardScrollTarget(false),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderLogo extends StatelessWidget {
  const _HeaderLogo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Image.asset(
        "assets/images/logo.png",
        width: 100,
        height: 90,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _HeroStatement extends StatelessWidget {
  const _HeroStatement();

  static const String _copy =
      "Turns complexity into clarity, connects what others keep separate, and creates momentum where others stall. A rare blend of systems thinker, cross-domain integrator, and practical catalyst.";

  @override
  Widget build(BuildContext context) {
    return Text(
      _copy,
      style: _Styles.hero,
      textAlign: TextAlign.left,
    );
  }
}

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({
    required this.expandedTiles,
    required this.onToggleAll,
    required this.onToggleTile,
    required this.allExpanded,
  });

  final List<bool> expandedTiles;
  final ValueChanged<bool> onToggleAll;
  final ValueChanged<int> onToggleTile;
  final bool allExpanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text("Explore My Skills", style: _Styles.h2)),
            const SizedBox(width: 16),
            _DetailsSwitch(value: allExpanded, onChanged: onToggleAll),
          ],
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < _skills.length; i++) ...<Widget>[
          _SkillTile(
            title: _skills[i].title,
            detail: _skills[i].detail,
            expanded: expandedTiles[i],
            onTap: () => onToggleTile(i),
          ),
          if (i != _skills.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SkillTile extends StatefulWidget {
  const _SkillTile({
    required this.title,
    required this.detail,
    required this.expanded,
    required this.onTap,
  });

  final String title;
  final String detail;
  final bool expanded;
  final VoidCallback onTap;

  @override
  State<_SkillTile> createState() => _SkillTileState();
}

class _SkillTileState extends State<_SkillTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool lift = _isHovered && !widget.expanded;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: Matrix4.translationValues(0, lift ? -2 : 0, 0),
          padding: EdgeInsets.fromLTRB(10, 8, 10, widget.expanded ? 6 : 7),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: lift ? _Palette.tileHoverBorder : const Color(0xFFBEBEBE),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(1),
            boxShadow: <BoxShadow>[
              if (widget.expanded)
                const BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              else if (lift)
                const BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                )
              else
                const BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(widget.title, style: _Styles.h3),
              if (widget.expanded) ...<Widget>[
                const SizedBox(height: 10),
                Text(widget.detail, style: _Styles.tileDetail),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsSwitch extends StatefulWidget {
  const _DetailsSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<_DetailsSwitch> createState() => _DetailsSwitchState();
}

class _DetailsSwitchState extends State<_DetailsSwitch> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = _isHovered && !widget.value
        ? _Palette.tileHoverBorder
        : widget.value
            ? _Palette.accent
            : const Color(0xFFBEBEBE);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Semantics(
        checked: widget.value,
        label: "Toggle tile details",
        child: GestureDetector(
          onTap: () => widget.onChanged(!widget.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 24,
            decoration: BoxDecoration(
              color: widget.value ? _Palette.accent : Colors.white,
              border: Border.all(color: borderColor, width: 1),
              borderRadius: BorderRadius.circular(999),
              boxShadow: <BoxShadow>[
                const BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                  spreadRadius: 0,
                ),
                if (_isHovered)
                  const BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  top: 3,
                  left: widget.value ? 23 : 3,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: widget.value ? Colors.white : _Palette.accent,
                      shape: BoxShape.circle,
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialSection extends StatelessWidget {
  const _SocialSection({required this.title, required this.entries});

  final String title;
  final List<_SocialItem> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: _Styles.h2.copyWith(fontSize: 34)),
        const SizedBox(height: 6),
        for (final _SocialItem entry in entries) ...<Widget>[
          _SocialRow(entry: entry),
        ],
      ],
    );
  }
}

class _SocialRow extends StatefulWidget {
  const _SocialRow({required this.entry});

  final _SocialItem entry;

  @override
  State<_SocialRow> createState() => _SocialRowState();
}

class _SocialRowState extends State<_SocialRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color color = _isHovered ? _Palette.socialHover : _Palette.social;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.entry.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Use IconTheme so both Material Icon and FaIcon inherit size/color.
              IconTheme(
                data: IconThemeData(size: 24, color: color),
                child: widget.entry.icon,
              ),
              const SizedBox(width: 8),
              Text(
                widget.entry.label,
                style: _Styles.socialLink.copyWith(
                  color: color,
                  decoration: _isHovered
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onOpenPrivacy});

  final VoidCallback onOpenPrivacy;

  @override
  Widget build(BuildContext context) {
    final int year = DateTime.now().year;
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 50),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9F7),
        border: Border(top: BorderSide(color: Color(0xFFE1E4F2), width: 2)),
      ),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 2,
          children: <Widget>[
            Text(
              "©$year T1 grid. All rights reserved.",
              style: _Styles.footerText,
              textAlign: TextAlign.center,
            ),
            _FooterLinkButton(
              label: "Privacy & Cookies Note.",
              onTap: onOpenPrivacy,
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterLinkButton extends StatefulWidget {
  const _FooterLinkButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_FooterLinkButton> createState() => _FooterLinkButtonState();
}

class _FooterLinkButtonState extends State<_FooterLinkButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: _Styles.footerLink.copyWith(
            color: _isHovered ? _Palette.hover : _Palette.social,
          ),
        ),
      ),
    );
  }
}

class _SocialItem {
  const _SocialItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;
}

class _SkillData {
  const _SkillData({
    required this.title,
    required this.detail,
  });

  final String title;
  final String detail;
}

class _Palette {
  static const Color accent = Color(0xFF394183);
  static const Color hover = Color(0xFF843F02);
  static const Color heading2 = Color(0xFF161C45);
  static const Color heading3 = Color(0xFF161C45);
  static const Color bodyText = Color(0xFF252525);
  static const Color social = accent;
  static const Color socialHover = hover;
  static const Color footerText = Color(0xFF555764);
  static const Color tileHoverBorder = hover;
}

class _Styles {
  static const TextStyle body = TextStyle(
    fontFamily: "Inter18pt",
    fontWeight: FontWeight.w300,
    fontSize: 17.3,
    height: 1.4,
    color: _Palette.bodyText,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: "ComingSoon",
    fontWeight: FontWeight.w700,
    fontSize: 35,
    height: 1,
    color: _Palette.heading2,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: "Inter18pt",
    fontWeight: FontWeight.w500,
    fontSize: 17.3,
    height: 1,
    color: _Palette.heading3,
  );

  static const TextStyle hero = TextStyle(
    fontFamily: "Inter18pt",
    fontWeight: FontWeight.w400,
    fontSize: 24,
    height: 1.35,
    letterSpacing: 0.1,
    color: _Palette.heading2,
  );

  static const TextStyle tileDetail = TextStyle(
    fontFamily: "Inter18pt",
    fontWeight: FontWeight.w300,
    fontSize: 16.4,
    height: 1.3,
    color: Color(0xFF111111),
  );

  static const TextStyle socialLink = TextStyle(
    fontFamily: "Inter18pt",
    fontWeight: FontWeight.w300,
    fontSize: 17.3,
    height: 1.2,
  );

  static const TextStyle footerText = TextStyle(
    fontFamily: "Inter18pt",
    fontWeight: FontWeight.w300,
    fontSize: 14,
    color: _Palette.footerText,
  );

  static const TextStyle footerLink = TextStyle(
    fontFamily: "Inter18pt",
    fontWeight: FontWeight.w300,
    fontSize: 14,
    color: _Palette.social,
    decoration: TextDecoration.underline,
  );
}

const List<_SkillData> _skills = <_SkillData>[
  _SkillData(
    title: "Identify -> Clarify -> Cut waste -> Coach for Change",
    detail: _defaultTileDetails,
  ),
  _SkillData(
    title: "Education",
    detail: _defaultTileDetails,
  ),
  _SkillData(
    title: "Advanced Data Analysis",
    detail: _defaultTileDetails,
  ),
  _SkillData(
    title: "Automating work",
    detail: _defaultTileDetails,
  ),
  _SkillData(
    title: "Creating joyful work processes & UI",
    detail: _defaultTileDetails,
  ),
  _SkillData(
    title: "Design & 3D-modeling",
    detail: _defaultTileDetails,
  ),
  _SkillData(
    title: "3D-printing",
    detail: _defaultTileDetails,
  ),
];

const String _defaultTileDetails = "(More info coming soon...)";
