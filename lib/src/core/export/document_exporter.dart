import 'dart:convert';
import '../../domain/models/editor_node.dart';

/// Export format options
enum ExportFormat {
  /// Plain text
  plainText,

  /// HTML document
  html,

  /// Markdown
  markdown,

  /// JSON (structured)
  json,
}

/// Options for export
class ExportOptions {
  /// Whether to include CSS styles (for HTML)
  final bool includeStyles;

  /// Whether to embed images as base64 (for HTML)
  final bool embedImages;

  /// Document title (for HTML)
  final String? title;

  /// CSS styles to include (for HTML)
  final String? customCss;

  /// Character encoding
  final String encoding;

  const ExportOptions({
    this.includeStyles = true,
    this.embedImages = false,
    this.title,
    this.customCss,
    this.encoding = 'utf-8',
  });
}

/// Utility class for exporting editor content
class DocumentExporter {
  DocumentExporter._();

  /// Exports nodes to the specified format
  static String export(
    List<EditorNode> nodes, {
    ExportFormat format = ExportFormat.html,
    ExportOptions options = const ExportOptions(),
  }) {
    switch (format) {
      case ExportFormat.plainText:
        return _exportPlainText(nodes);
      case ExportFormat.html:
        return _exportHtml(nodes, options);
      case ExportFormat.markdown:
        return _exportMarkdown(nodes);
      case ExportFormat.json:
        return _exportJson(nodes);
    }
  }

  /// Exports to plain text
  static String _exportPlainText(List<EditorNode> nodes) {
    final buffer = StringBuffer();

    for (final node in nodes) {
      if (node is ParagraphNode) {
        buffer.writeln(node.plainText);
        buffer.writeln();
      } else if (node is ListNode) {
        for (int i = 0; i < node.items.length; i++) {
          final item = node.items[i];
          final prefix = node.listType.isOrdered ? '${i + 1}. ' : '• ';
          buffer.writeln('$prefix${item.plainText}');
        }
        buffer.writeln();
      } else if (node is CodeBlockNode) {
        buffer.writeln('---');
        buffer.writeln(node.code);
        buffer.writeln('---');
        buffer.writeln();
      } else if (node is HorizontalRuleNode) {
        buffer.writeln('────────────────────');
        buffer.writeln();
      } else if (node is ImageNode) {
        buffer.writeln('[Image: ${node.alt.isNotEmpty ? node.alt : node.src}]');
        buffer.writeln();
      }
    }

    return buffer.toString().trimRight();
  }

  /// Exports to HTML document
  static String _exportHtml(List<EditorNode> nodes, ExportOptions options) {
    final content = nodes.map((n) => n.toHtml()).join('\n');

    if (!options.includeStyles) {
      return content;
    }

    final title = options.title ?? 'Document';
    final css = options.customCss ?? _defaultCss;

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="${options.encoding}">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <style>
$css
    </style>
</head>
<body>
    <article class="document">
$content
    </article>
</body>
</html>
''';
  }

  /// Exports to Markdown
  static String _exportMarkdown(List<EditorNode> nodes) {
    final buffer = StringBuffer();

    for (final node in nodes) {
      if (node is ParagraphNode) {
        String prefix = '';
        switch (node.type.htmlTag) {
          case 'h1':
            prefix = '# ';
            break;
          case 'h2':
            prefix = '## ';
            break;
          case 'h3':
            prefix = '### ';
            break;
          case 'h4':
            prefix = '#### ';
            break;
          case 'h5':
            prefix = '##### ';
            break;
          case 'h6':
            prefix = '###### ';
            break;
          case 'blockquote':
            prefix = '> ';
            break;
        }

        String text = _convertSpansToMarkdown(node.children);
        buffer.writeln('$prefix$text');
        buffer.writeln();
      } else if (node is ListNode) {
        for (int i = 0; i < node.items.length; i++) {
          final item = node.items[i];
          final prefix = node.listType.isOrdered ? '${i + 1}. ' : '- ';
          buffer.writeln('$prefix${_convertSpansToMarkdown(item.children)}');
        }
        buffer.writeln();
      } else if (node is CodeBlockNode) {
        final lang = node.language ?? '';
        buffer.writeln('```$lang');
        buffer.writeln(node.code);
        buffer.writeln('```');
        buffer.writeln();
      } else if (node is HorizontalRuleNode) {
        buffer.writeln('---');
        buffer.writeln();
      } else if (node is ImageNode) {
        buffer.writeln('![${node.alt}](${node.src})');
        buffer.writeln();
      } else if (node is LinkNode) {
        buffer.writeln('[${node.text}](${node.href})');
      } else if (node is TableNode) {
        _writeMarkdownTable(buffer, node);
        buffer.writeln();
      }
    }

    return buffer.toString().trimRight();
  }

  static String _convertSpansToMarkdown(List<TextSpanNode> spans) {
    final buffer = StringBuffer();

    for (final span in spans) {
      String text = span.text;

      if (span.style.isBold) {
        text = '**$text**';
      }
      if (span.style.isItalic) {
        text = '*$text*';
      }
      if (span.style.isStrikethrough) {
        text = '~~$text~~';
      }
      if (span.style.isCode) {
        text = '`$text`';
      }

      buffer.write(text);
    }

    return buffer.toString();
  }

  static void _writeMarkdownTable(StringBuffer buffer, TableNode table) {
    if (table.rows.isEmpty) return;

    // Header row
    final headerRow = table.rows.first;
    buffer.write('|');
    for (final cell in headerRow.cells) {
      final text = cell.children.map((s) => s.text).join();
      buffer.write(' $text |');
    }
    buffer.writeln();

    // Separator
    buffer.write('|');
    for (int i = 0; i < headerRow.cells.length; i++) {
      buffer.write(' --- |');
    }
    buffer.writeln();

    // Data rows
    for (int i = 1; i < table.rows.length; i++) {
      final row = table.rows[i];
      buffer.write('|');
      for (final cell in row.cells) {
        final text = cell.children.map((s) => s.text).join();
        buffer.write(' $text |');
      }
      buffer.writeln();
    }
  }

  /// Exports to JSON
  static String _exportJson(List<EditorNode> nodes) {
    final data = {
      'version': '1.0',
      'nodes': nodes.map((n) => _nodeToJson(n)).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static Map<String, dynamic> _nodeToJson(EditorNode node) {
    if (node is ParagraphNode) {
      return {
        'type': 'paragraph',
        'paragraphType': node.type.name,
        'alignment': node.alignment.name,
        'indentLevel': node.indentLevel,
        'children': node.children.map((s) => _spanToJson(s)).toList(),
      };
    } else if (node is ListNode) {
      return {
        'type': 'list',
        'listType': node.listType.name,
        'items': node.items.map((item) => {
          'children': item.children.map((s) => _spanToJson(s)).toList(),
        }).toList(),
      };
    } else if (node is CodeBlockNode) {
      return {
        'type': 'codeBlock',
        'code': node.code,
        'language': node.language,
      };
    } else if (node is TableNode) {
      return {
        'type': 'table',
        'hasHeader': node.hasHeader,
        'rows': node.rows.map((row) => {
          'cells': row.cells.map((cell) => {
            'isHeader': cell.isHeader,
            'colSpan': cell.colSpan,
            'rowSpan': cell.rowSpan,
            'children': cell.children.map((s) => _spanToJson(s)).toList(),
          }).toList(),
        }).toList(),
      };
    } else if (node is HorizontalRuleNode) {
      return {'type': 'horizontalRule'};
    } else if (node is ImageNode) {
      return {
        'type': 'image',
        'src': node.src,
        'alt': node.alt,
        'width': node.width,
        'height': node.height,
      };
    } else if (node is LinkNode) {
      return {
        'type': 'link',
        'href': node.href,
        'text': node.text,
        'openInNewTab': node.openInNewTab,
      };
    }

    return {'type': 'unknown'};
  }

  static Map<String, dynamic> _spanToJson(TextSpanNode span) {
    return {
      'text': span.text,
      'style': {
        'formats': span.style.formats.map((f) => f.name).toList(),
        'textColor': span.style.textColor?.value,
        'backgroundColor': span.style.backgroundColor?.value,
        'fontSize': span.style.fontSize,
      },
    };
  }

  /// Default CSS for HTML export
  static const String _defaultCss = '''
    * {
      box-sizing: border-box;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
    }

    .document {
      background: #fff;
    }

    h1, h2, h3, h4, h5, h6 {
      margin-top: 24px;
      margin-bottom: 16px;
      font-weight: 600;
      line-height: 1.25;
    }

    h1 { font-size: 2em; border-bottom: 1px solid #eee; padding-bottom: 0.3em; }
    h2 { font-size: 1.5em; border-bottom: 1px solid #eee; padding-bottom: 0.3em; }
    h3 { font-size: 1.25em; }
    h4 { font-size: 1em; }
    h5 { font-size: 0.875em; }
    h6 { font-size: 0.85em; color: #666; }

    p {
      margin-top: 0;
      margin-bottom: 16px;
    }

    a {
      color: #0366d6;
      text-decoration: none;
    }

    a:hover {
      text-decoration: underline;
    }

    ul, ol {
      margin-top: 0;
      margin-bottom: 16px;
      padding-left: 2em;
    }

    li {
      margin-bottom: 4px;
    }

    blockquote {
      margin: 0;
      padding: 0 1em;
      color: #666;
      border-left: 4px solid #ddd;
    }

    pre {
      background: #f6f8fa;
      border-radius: 6px;
      padding: 16px;
      overflow: auto;
      font-size: 14px;
      line-height: 1.45;
    }

    code {
      font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
      font-size: 85%;
      background: rgba(27, 31, 35, 0.05);
      border-radius: 3px;
      padding: 0.2em 0.4em;
    }

    pre code {
      background: none;
      padding: 0;
    }

    table {
      border-collapse: collapse;
      width: 100%;
      margin-bottom: 16px;
    }

    th, td {
      border: 1px solid #ddd;
      padding: 8px 12px;
      text-align: left;
    }

    th {
      background: #f6f8fa;
      font-weight: 600;
    }

    hr {
      border: none;
      border-top: 1px solid #ddd;
      margin: 24px 0;
    }

    img {
      max-width: 100%;
      height: auto;
    }

    @media print {
      body {
        max-width: none;
        padding: 0;
      }

      pre {
        white-space: pre-wrap;
        word-wrap: break-word;
      }
    }
  ''';
}

/// Result of an import operation
class ImportResult {
  /// The imported nodes
  final List<EditorNode> nodes;

  /// Any warnings during import
  final List<String> warnings;

  /// Whether the import was successful
  final bool success;

  /// Error message if import failed
  final String? error;

  const ImportResult({
    required this.nodes,
    this.warnings = const [],
    this.success = true,
    this.error,
  });

  factory ImportResult.failure(String error) {
    return ImportResult(
      nodes: [],
      success: false,
      error: error,
    );
  }
}

/// Utility for importing content
class DocumentImporter {
  DocumentImporter._();

  /// Imports content from the specified format
  static ImportResult import(
    String content, {
    ExportFormat format = ExportFormat.html,
  }) {
    try {
      switch (format) {
        case ExportFormat.plainText:
          return _importPlainText(content);
        case ExportFormat.html:
          return _importHtml(content);
        case ExportFormat.markdown:
          return _importMarkdown(content);
        case ExportFormat.json:
          return _importJson(content);
      }
    } catch (e) {
      return ImportResult.failure(e.toString());
    }
  }

  static ImportResult _importPlainText(String content) {
    final lines = content.split('\n');
    final nodes = <EditorNode>[];

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      nodes.add(ParagraphNode(
        children: [TextSpanNode(text: line)],
      ));
    }

    if (nodes.isEmpty) {
      nodes.add(ParagraphNode(children: [TextSpanNode(text: '')]));
    }

    return ImportResult(nodes: nodes);
  }

  static ImportResult _importHtml(String content) {
    // Use the existing HTML parser
    // This is a simplified version
    final nodes = <EditorNode>[];
    final warnings = <String>[];

    // Strip HTML document wrapper if present
    String body = content;
    final bodyMatch = RegExp(r'<body[^>]*>([\s\S]*)</body>', caseSensitive: false)
        .firstMatch(content);
    if (bodyMatch != null) {
      body = bodyMatch.group(1) ?? content;
    }

    // Parse basic tags
    final tagRegex = RegExp(
      r'<(p|h[1-6]|ul|ol|pre|blockquote|hr)[^>]*>([\s\S]*?)</\1>|<hr\s*/?>',
      caseSensitive: false,
    );

    final matches = tagRegex.allMatches(body);

    if (matches.isEmpty) {
      // Treat as plain text
      nodes.add(ParagraphNode(
        children: [TextSpanNode(text: _stripTags(body).trim())],
      ));
    } else {
      for (final match in matches) {
        final tag = match.group(1)?.toLowerCase();
        final innerContent = match.group(2) ?? '';

        if (tag == null || match.group(0)?.startsWith('<hr') == true) {
          nodes.add(HorizontalRuleNode());
          continue;
        }

        switch (tag) {
          case 'p':
            nodes.add(ParagraphNode(
              children: [TextSpanNode(text: _stripTags(innerContent).trim())],
            ));
            break;
          case 'h1':
          case 'h2':
          case 'h3':
          case 'h4':
          case 'h5':
          case 'h6':
            nodes.add(ParagraphNode(
              children: [TextSpanNode(text: _stripTags(innerContent).trim())],
            ));
            break;
          default:
            nodes.add(ParagraphNode(
              children: [TextSpanNode(text: _stripTags(innerContent).trim())],
            ));
        }
      }
    }

    if (nodes.isEmpty) {
      nodes.add(ParagraphNode(children: [TextSpanNode(text: '')]));
    }

    return ImportResult(nodes: nodes, warnings: warnings);
  }

  static ImportResult _importMarkdown(String content) {
    final nodes = <EditorNode>[];
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().isEmpty) continue;

      // Headers
      final headerMatch = RegExp(r'^(#{1,6})\s+(.*)').firstMatch(line);
      if (headerMatch != null) {
        nodes.add(ParagraphNode(
          children: [TextSpanNode(text: headerMatch.group(2)!.trim())],
        ));
        continue;
      }

      // Horizontal rule
      if (RegExp(r'^[-*_]{3,}$').hasMatch(line.trim())) {
        nodes.add(HorizontalRuleNode());
        continue;
      }

      // Code block
      if (line.startsWith('```')) {
        final codeLines = <String>[];
        i++;
        while (i < lines.length && !lines[i].startsWith('```')) {
          codeLines.add(lines[i]);
          i++;
        }
        nodes.add(CodeBlockNode(code: codeLines.join('\n')));
        continue;
      }

      // Regular paragraph
      nodes.add(ParagraphNode(
        children: [TextSpanNode(text: line.trim())],
      ));
    }

    if (nodes.isEmpty) {
      nodes.add(ParagraphNode(children: [TextSpanNode(text: '')]));
    }

    return ImportResult(nodes: nodes);
  }

  static ImportResult _importJson(String content) {
    final data = jsonDecode(content) as Map<String, dynamic>;
    final nodesList = data['nodes'] as List<dynamic>? ?? [];
    final nodes = <EditorNode>[];

    for (final nodeData in nodesList) {
      final type = nodeData['type'] as String?;

      switch (type) {
        case 'paragraph':
          final text = (nodeData['children'] as List?)
              ?.map((c) => c['text'] as String? ?? '')
              .join() ?? '';
          nodes.add(ParagraphNode(
            children: [TextSpanNode(text: text)],
          ));
          break;
        case 'codeBlock':
          nodes.add(CodeBlockNode(
            code: nodeData['code'] as String? ?? '',
            language: nodeData['language'] as String?,
          ));
          break;
        case 'horizontalRule':
          nodes.add(HorizontalRuleNode());
          break;
        default:
          // Skip unknown types
          break;
      }
    }

    if (nodes.isEmpty) {
      nodes.add(ParagraphNode(children: [TextSpanNode(text: '')]));
    }

    return ImportResult(nodes: nodes);
  }

  static String _stripTags(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }
}
