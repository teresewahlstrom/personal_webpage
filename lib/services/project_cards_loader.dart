import 'package:flutter/services.dart' show rootBundle;
import 'package:tw_primitives/markdown.dart';
import '../models/project_card_data.dart' show ProjectCardData;

class ProjectCardsContent {
  const ProjectCardsContent({required this.cards});

  final List<ProjectCardData> cards;
}

class ProjectCardsMarkdownLoader {
  const ProjectCardsMarkdownLoader._();

  static const List<String> projectCardAssetPaths = <String>[
    'lib/subjects/Terese/professional_story/capability_architect.md',
    'lib/subjects/Terese/professional_story/product_rd_engineer.md',
    'lib/subjects/Terese/professional_story/cross_functional_leader.md',
    'lib/subjects/Terese/professional_story/metal_am_specialist.md',
    'lib/subjects/Terese/professional_story/computational_engineer.md',
    'lib/subjects/Terese/professional_story/ai_systems_for_technical_work.md',
  ];

  static Future<ProjectCardsContent> loadProjectCards() async {
    final List<ProjectCardData> cards = await Future.wait(
      projectCardAssetPaths.map((String assetPath) async {
        final String markdown = await rootBundle.loadString(assetPath);
        return parse(
          markdown,
          sourceAssetPath: assetPath,
        );
      }),
    );
    return ProjectCardsContent(cards: cards);
  }

  static ProjectCardData parse(
    String markdown, {
    required String sourceAssetPath,
  }) {
    final _FrontmatterDocument document = _parseFrontmatter(
      markdown,
      sourceAssetPath: sourceAssetPath,
    );
    final Map<String, String> metadata = document.metadata;

    final String id = _requiredValue(metadata, 'id', sourceAssetPath);
    final String title = _requiredValue(metadata, 'title', sourceAssetPath);
    final String description = _requiredValue(
      metadata,
      'short',
      sourceAssetPath,
    );
    final String category = _requiredValue(
      metadata,
      'category',
      sourceAssetPath,
    );
    final String imagePath = _requiredValue(metadata, 'image', sourceAssetPath);
    final String orderText = _requiredValue(metadata, 'order', sourceAssetPath);
    final int? order = int.tryParse(orderText);

    if (order == null) {
      throw FormatException(
        'Professional story metadata "order" must be an integer in $sourceAssetPath.',
      );
    }
    if (document.body.isEmpty) {
      throw FormatException(
        'Professional story body is empty in $sourceAssetPath.',
      );
    }

    return ProjectCardData(
      id: id,
      title: title,
      description: description,
      category: category,
      imagePath: imagePath,
      contentDocument: MessageMarkup.parse(document.body),
      order: order,
    );
  }

  static _FrontmatterDocument _parseFrontmatter(
    String markdown, {
    required String sourceAssetPath,
  }) {
    final List<String> lines = markdown.replaceAll('\r\n', '\n').split('\n');
    if (lines.isEmpty || lines.first.trim() != '---') {
      throw FormatException(
        'Professional story markdown must start with frontmatter in $sourceAssetPath.',
      );
    }

    final Map<String, String> metadata = <String, String>{};
    int? closingFenceIndex;

    for (int i = 1; i < lines.length; i++) {
      final String line = lines[i];
      if (line.trim() == '---') {
        closingFenceIndex = i;
        break;
      }

      final int separatorIndex = line.indexOf(':');
      if (separatorIndex <= 0) {
        throw FormatException(
          'Invalid frontmatter line in $sourceAssetPath: $line',
        );
      }

      final String key = line.substring(0, separatorIndex).trim();
      final String value = line.substring(separatorIndex + 1).trim();
      if (key.isEmpty || value.isEmpty) {
        throw FormatException(
          'Invalid frontmatter key/value in $sourceAssetPath: $line',
        );
      }
      metadata[key] = value;
    }

    if (closingFenceIndex == null) {
      throw FormatException(
        'Professional story markdown is missing closing frontmatter fence in $sourceAssetPath.',
      );
    }

    return _FrontmatterDocument(
      metadata: metadata,
      body: lines.skip(closingFenceIndex + 1).join('\n').trim(),
    );
  }

  static String _requiredValue(
    Map<String, String> metadata,
    String key,
    String sourceAssetPath,
  ) {
    final String? value = metadata[key];
    if (value == null || value.trim().isEmpty) {
      throw FormatException(
        'Professional story metadata "$key" is missing in $sourceAssetPath.',
      );
    }
    return value.trim();
  }
}

class _FrontmatterDocument {
  const _FrontmatterDocument({required this.metadata, required this.body});

  final Map<String, String> metadata;
  final String body;
}
