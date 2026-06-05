import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// A widget that configures SEO metadata (title, description, and Open Graph tags)
/// on Flutter Web. Safe to use on all platforms.
class SeoMeta extends StatefulWidget {
  final String title;
  final String description;
  final String? ogImage;
  final String? canonicalUrl;
  final Widget child;

  const SeoMeta({
    super.key,
    required this.title,
    required this.description,
    this.ogImage,
    this.canonicalUrl,
    required this.child,
  });

  @override
  State<SeoMeta> createState() => _SeoMetaState();
}

class _SeoMetaState extends State<SeoMeta> {
  @override
  void initState() {
    super.initState();
    _updateMetadata();
  }

  @override
  void didUpdateWidget(covariant SeoMeta oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.title != oldWidget.title ||
        widget.description != oldWidget.description ||
        widget.ogImage != oldWidget.ogImage ||
        widget.canonicalUrl != oldWidget.canonicalUrl) {
      _updateMetadata();
    }
  }

  void _updateMetadata() {
    if (!kIsWeb) return;

    try {
      // 1. Update document title
      web.document.title = widget.title;

      // 2. Update meta tags in the document head
      _setMetaTag('description', widget.description);
      _setMetaTag('og:title', widget.title);
      _setMetaTag('og:description', widget.description);

      if (widget.ogImage != null) {
        _setMetaTag('og:image', widget.ogImage!);
        _setMetaTag('twitter:image', widget.ogImage!);
      }

      _setMetaTag('twitter:card', 'summary_large_image');
      _setMetaTag('twitter:title', widget.title);
      _setMetaTag('twitter:description', widget.description);

      if (widget.canonicalUrl != null) {
        _setLinkTag('canonical', widget.canonicalUrl!);
      }

      // Add a signal attribute to document element indicating SEO meta tags have loaded.
      // This helps the headless pre-renderer know the DOM is updated.
      web.document.documentElement?.setAttribute('data-seo-ready', 'true');
    } catch (e) {
      // Gracefully catch any browser interaction issues in headless environments
      debugPrint('Error updating SEO metadata: $e');
    }
  }

  void _setMetaTag(String name, String content) {
    final head = web.document.head;
    if (head == null) return;

    // Search for existing meta tags by name or property
    web.Element? element = web.document.querySelector('meta[name="$name"]') ??
        web.document.querySelector('meta[property="$name"]');

    if (element == null) {
      element = web.document.createElement('meta');
      if (name.startsWith('og:')) {
        element.setAttribute('property', name);
      } else {
        element.setAttribute('name', name);
      }
      head.appendChild(element);
    }
    element.setAttribute('content', content);
  }

  void _setLinkTag(String rel, String href) {
    final head = web.document.head;
    if (head == null) return;

    web.Element? element = web.document.querySelector('link[rel="$rel"]');
    if (element == null) {
      element = web.document.createElement('link');
      element.setAttribute('rel', rel);
      head.appendChild(element);
    }
    element.setAttribute('href', href);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
