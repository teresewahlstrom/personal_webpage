import 'package:tw_primitives/markdown.dart';

class ProjectCardData {
  const ProjectCardData({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imagePath,
    required this.contentDocument,
    required this.order,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String imagePath;
  final MarkupDocument contentDocument;
  final int order;
}
