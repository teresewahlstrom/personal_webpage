import 'dart:io';

void main() {
  final root = Directory.current;
  final rules = <_GuardRule>[
    _GuardRule(
      forbiddenWidget:
          'Selection'
          'Area',
      allowedFiles: <String>{
        _normalize(
          'packages/tw_primitives/lib/src/selection/selectable_region_fork.dart',
        ),
      },
      replacement: 'TwSelectableRegion or TwSelectableScrollArea',
    ),
    _GuardRule(
      forbiddenWidget:
          'Text'
          'Field',
      replacement: 'TwReadyTextField',
    ),
    _GuardRule(
      forbiddenWidget:
          'Text'
          'Form'
          'Field',
      replacement: 'TwReadyTextField',
    ),
    _GuardRule(
      forbiddenWidget:
          'Editable'
          'Text',
      replacement: 'TwReadyTextField or TwTextField',
    ),
  ];
  final ignoredDirectories = <String>{
    '.dart_tool',
    '.git',
    'build',
    'node_modules',
  };
  final violations = <_Violation>[];

  void scanDirectory(Directory directory) {
    for (final entity in directory.listSync(followLinks: false)) {
      final name = entity.uri.pathSegments.isEmpty
          ? ''
          : entity.uri.pathSegments.last.replaceFirst(RegExp(r'/$'), '');
      if (entity is Directory) {
        if (!ignoredDirectories.contains(name)) {
          scanDirectory(entity);
        }
        continue;
      }
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final relativePath = _normalize(
        entity.path.substring(root.path.length + 1),
      );
      final lines = entity.readAsLinesSync();
      for (var index = 0; index < lines.length; index += 1) {
        final line = lines[index];
        for (final rule in rules) {
          if (rule.allowedFiles.contains(relativePath)) {
            continue;
          }
          if (rule.pattern.hasMatch(line)) {
            violations.add(
              _Violation(
                rule: rule,
                relativePath: relativePath,
                lineNumber: index + 1,
                line: line.trim(),
              ),
            );
          }
        }
      }
    }
  }

  scanDirectory(root);

  if (violations.isNotEmpty) {
    stderr.writeln('Raw Flutter primitives are not allowed here.');
    stderr.writeln();
    for (final violation in violations) {
      stderr.writeln(
        '  ${violation.relativePath}:${violation.lineNumber}: ${violation.line}',
      );
      stderr.writeln(
        '    Use ${violation.rule.replacement} instead of ${violation.rule.forbiddenWidget}.',
      );
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Tw primitive usage check passed.');
}

final class _GuardRule {
  _GuardRule({
    required this.forbiddenWidget,
    required this.replacement,
    Set<String>? allowedFiles,
  }) : allowedFiles = allowedFiles ?? <String>{},
       pattern = RegExp('\\b${RegExp.escape(forbiddenWidget)}\\s*\\(');

  final String forbiddenWidget;
  final String replacement;
  final Set<String> allowedFiles;
  final RegExp pattern;
}

final class _Violation {
  const _Violation({
    required this.rule,
    required this.relativePath,
    required this.lineNumber,
    required this.line,
  });

  final _GuardRule rule;
  final String relativePath;
  final int lineNumber;
  final String line;
}

String _normalize(String path) => path.replaceAll('\\', '/');
