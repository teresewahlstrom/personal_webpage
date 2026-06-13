import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// A widget that injects a JSON-LD structured data schema (schema.org)
/// into the document head on Flutter Web. Safe to use on all platforms.
class SeoSchema extends StatefulWidget {
  final Map<String, dynamic> schemaData;
  final Widget child;

  const SeoSchema({
    super.key,
    required this.schemaData,
    required this.child,
  });

  @override
  State<SeoSchema> createState() => _SeoSchemaState();
}

class _SeoSchemaState extends State<SeoSchema> {
  @override
  void initState() {
    super.initState();
    _updateSchema();
  }

  @override
  void didUpdateWidget(covariant SeoSchema oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.schemaData != oldWidget.schemaData) {
      _updateSchema();
    }
  }

  void _updateSchema() {
    if (!kIsWeb) return;

    try {
      final head = web.document.head;
      if (head == null) return;

      // Find or create LD+JSON script tag
      web.Element? element = web.document.querySelector('script[type="application/ld+json"]');
      if (element == null) {
        element = web.document.createElement('script');
        element.setAttribute('type', 'application/ld+json');
        head.appendChild(element);
      }

      // Add schema context if not present
      final Map<String, dynamic> fullSchema = Map<String, dynamic>.from(widget.schemaData);
      if (!fullSchema.containsKey('@context')) {
        fullSchema['@context'] = 'https://schema.org';
      }

      element.textContent = jsonEncode(fullSchema);
    } catch (e) {
      debugPrint('Error updating SEO schema: $e');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
