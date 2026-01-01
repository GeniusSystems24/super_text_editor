import 'package:flutter/material.dart';
import '../../domain/enums/list_type.dart';
import '../../domain/enums/paragraph_type.dart';
import '../../domain/enums/text_format.dart';
import '../../domain/models/editor_node.dart';
import '../../domain/models/text_style_model.dart';

/// Utility class for parsing and generating HTML
class HtmlParser {
  HtmlParser._();

  /// Parses HTML string into a list of EditorNodes
  static List<EditorNode> parse(String html) {
    final nodes = <EditorNode>[];

    // Simple regex-based parsing
    // For production, consider using html package

    // Remove extra whitespace
    html = html.trim();

    if (html.isEmpty) {
      return [ParagraphNode(children: [TextSpanNode(text: '')])];
    }

    // Split by block-level elements
    final blockRegex = RegExp(
      r'<(p|h[1-6]|pre|blockquote|ul|ol|li|table|hr|div)[^>]*>(.*?)</\1>|<hr\s*/?>',
      caseSensitive: false,
      dotAll: true,
    );

    final matches = blockRegex.allMatches(html);

    if (matches.isEmpty) {
      // No block elements, treat as plain text
      nodes.add(ParagraphNode(
        children: _parseInlineContent(html),
      ));
    } else {
      for (final match in matches) {
        final tag = match.group(1)?.toLowerCase();
        final content = match.group(2) ?? '';

        if (tag == null || match.group(0) == '<hr>' || match.group(0) == '<hr/>') {
          nodes.add(HorizontalRuleNode());
          continue;
        }

        switch (tag) {
          case 'p':
            nodes.add(ParagraphNode(
              type: ParagraphType.paragraph,
              children: _parseInlineContent(content),
            ));
            break;
          case 'h1':
            nodes.add(ParagraphNode(
              type: ParagraphType.heading1,
              children: _parseInlineContent(content),
            ));
            break;
          case 'h2':
            nodes.add(ParagraphNode(
              type: ParagraphType.heading2,
              children: _parseInlineContent(content),
            ));
            break;
          case 'h3':
            nodes.add(ParagraphNode(
              type: ParagraphType.heading3,
              children: _parseInlineContent(content),
            ));
            break;
          case 'h4':
            nodes.add(ParagraphNode(
              type: ParagraphType.heading4,
              children: _parseInlineContent(content),
            ));
            break;
          case 'h5':
            nodes.add(ParagraphNode(
              type: ParagraphType.heading5,
              children: _parseInlineContent(content),
            ));
            break;
          case 'h6':
            nodes.add(ParagraphNode(
              type: ParagraphType.heading6,
              children: _parseInlineContent(content),
            ));
            break;
          case 'pre':
            nodes.add(CodeBlockNode(
              code: _stripTags(content),
              language: _extractLanguage(content),
            ));
            break;
          case 'blockquote':
            nodes.add(ParagraphNode(
              type: ParagraphType.blockquote,
              children: _parseInlineContent(content),
            ));
            break;
          case 'ul':
            nodes.add(_parseList(content, ListType.bullet));
            break;
          case 'ol':
            nodes.add(_parseList(content, _extractListType(match.group(0) ?? '')));
            break;
          default:
            nodes.add(ParagraphNode(
              children: _parseInlineContent(content),
            ));
        }
      }
    }

    if (nodes.isEmpty) {
      nodes.add(ParagraphNode(children: [TextSpanNode(text: '')]));
    }

    return nodes;
  }

  /// Parses inline content and returns TextSpanNodes
  static List<TextSpanNode> _parseInlineContent(String html) {
    final spans = <TextSpanNode>[];

    // Simple parsing - strip tags and create single span
    // For production, parse each inline element

    final text = _stripTags(html)
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('<br>', '\n')
        .replaceAll('<br/>', '\n')
        .replaceAll('<br />', '\n');

    // Detect formatting from HTML
    final formats = <TextFormat>{};
    if (html.contains('<strong>') || html.contains('<b>')) {
      formats.add(TextFormat.bold);
    }
    if (html.contains('<em>') || html.contains('<i>')) {
      formats.add(TextFormat.italic);
    }
    if (html.contains('<u>')) {
      formats.add(TextFormat.underline);
    }
    if (html.contains('<s>') || html.contains('<strike>') || html.contains('<del>')) {
      formats.add(TextFormat.strikethrough);
    }
    if (html.contains('<sub>')) {
      formats.add(TextFormat.subscript);
    }
    if (html.contains('<sup>')) {
      formats.add(TextFormat.superscript);
    }
    if (html.contains('<code>') && !html.contains('<pre>')) {
      formats.add(TextFormat.code);
    }

    // Extract color
    Color? textColor;
    final colorMatch = RegExp(r'color:\s*([#\w]+)').firstMatch(html);
    if (colorMatch != null) {
      textColor = _parseColor(colorMatch.group(1));
    }

    // Extract background color
    Color? backgroundColor;
    final bgMatch = RegExp(r'background-color:\s*([#\w]+)').firstMatch(html);
    if (bgMatch != null) {
      backgroundColor = _parseColor(bgMatch.group(1));
    }

    spans.add(TextSpanNode(
      text: text,
      style: TextStyleModel(
        formats: formats,
        textColor: textColor,
        backgroundColor: backgroundColor,
      ),
    ));

    return spans;
  }

  /// Parses a list element
  static ListNode _parseList(String html, ListType type) {
    final items = <ListItemNode>[];

    final liRegex = RegExp(r'<li[^>]*>(.*?)</li>', caseSensitive: false, dotAll: true);
    final matches = liRegex.allMatches(html);

    for (final match in matches) {
      final content = match.group(1) ?? '';
      items.add(ListItemNode(
        children: _parseInlineContent(content),
      ));
    }

    return ListNode(listType: type, items: items);
  }

  /// Extracts list type from ol tag
  static ListType _extractListType(String html) {
    if (html.contains('lower-roman')) return ListType.lowerRoman;
    if (html.contains('upper-roman')) return ListType.upperRoman;
    if (html.contains('lower-alpha')) return ListType.lowerAlpha;
    if (html.contains('upper-alpha')) return ListType.upperAlpha;
    if (html.contains('decimal-leading-zero')) return ListType.decimalLeadingZero;
    return ListType.decimal;
  }

  /// Extracts language from code block
  static String? _extractLanguage(String html) {
    final match = RegExp(r'class="language-(\w+)"').firstMatch(html);
    return match?.group(1);
  }

  /// Strips HTML tags from string
  static String _stripTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Parses color string to Color
  static Color? _parseColor(String? colorStr) {
    if (colorStr == null) return null;

    if (colorStr.startsWith('#')) {
      final hex = colorStr.substring(1);
      if (hex.length == 6) {
        final value = int.tryParse(hex, radix: 16);
        if (value != null) {
          return Color(0xFF000000 | value);
        }
      }
    }

    // Named colors
    switch (colorStr.toLowerCase()) {
      case 'red': return Colors.red;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'yellow': return Colors.yellow;
      case 'black': return Colors.black;
      case 'white': return Colors.white;
      case 'gray':
      case 'grey': return Colors.grey;
      default: return null;
    }
  }

  /// Converts EditorNodes to HTML string
  static String toHtml(List<EditorNode> nodes) {
    final buffer = StringBuffer();

    for (final node in nodes) {
      buffer.writeln(node.toHtml());
    }

    return buffer.toString().trim();
  }

  /// Converts EditorNodes to plain text
  static String toPlainText(List<EditorNode> nodes) {
    final buffer = StringBuffer();

    for (final node in nodes) {
      if (node is ParagraphNode) {
        buffer.writeln(node.plainText);
      } else if (node is ListNode) {
        for (final item in node.items) {
          buffer.writeln('• ${item.plainText}');
        }
      } else if (node is CodeBlockNode) {
        buffer.writeln(node.code);
      } else if (node is HorizontalRuleNode) {
        buffer.writeln('---');
      }
    }

    return buffer.toString().trimRight();
  }
}
