import '../../core/document/document.dart';
import '../../core/document/nodes.dart';
import '../../core/document/attributed_text.dart';

/// Imports HTML into a document
class HtmlImporter {
  /// Creates a new HTML importer
  const HtmlImporter();

  /// Imports HTML and returns a document
  Document import(String html) {
    final nodes = <DocumentNode>[];

    // Simple regex-based parsing for MVP
    // A proper implementation would use an HTML parser
    final cleanHtml = html.trim();

    // Parse block elements
    final blockPattern = RegExp(
      r'<(p|h[1-6]|blockquote|pre|ul|ol|table|img|hr)([^>]*)>(.*?)</\1>|<(img|hr)([^>]*)/?>'
      r'|<(ul|ol)([^>]*)>(.*?)</\6>',
      multiLine: true,
      dotAll: true,
    );

    int lastEnd = 0;
    for (final match in blockPattern.allMatches(cleanHtml)) {
      // Handle text between blocks
      if (match.start > lastEnd) {
        final textBetween = cleanHtml.substring(lastEnd, match.start).trim();
        if (textBetween.isNotEmpty) {
          nodes.add(ParagraphNode.fromText(_stripHtml(textBetween)));
        }
      }

      final tag = match.group(1) ?? match.group(4) ?? match.group(6);
      final attrs = match.group(2) ?? match.group(5) ?? match.group(7) ?? '';
      final content = match.group(3) ?? match.group(8) ?? '';

      switch (tag?.toLowerCase()) {
        case 'p':
          nodes.add(_parseParagraph(content, attrs, BlockType.paragraph));
          break;
        case 'h1':
          nodes.add(_parseParagraph(content, attrs, BlockType.heading1));
          break;
        case 'h2':
          nodes.add(_parseParagraph(content, attrs, BlockType.heading2));
          break;
        case 'h3':
          nodes.add(_parseParagraph(content, attrs, BlockType.heading3));
          break;
        case 'h4':
          nodes.add(_parseParagraph(content, attrs, BlockType.heading4));
          break;
        case 'h5':
          nodes.add(_parseParagraph(content, attrs, BlockType.heading5));
          break;
        case 'h6':
          nodes.add(_parseParagraph(content, attrs, BlockType.heading6));
          break;
        case 'blockquote':
          nodes.add(_parseParagraph(content, attrs, BlockType.blockquote));
          break;
        case 'pre':
          nodes.add(_parseCodeBlock(content, attrs));
          break;
        case 'ul':
          nodes.addAll(_parseList(content, ListType.bullet));
          break;
        case 'ol':
          nodes.addAll(_parseList(content, ListType.numbered));
          break;
        case 'table':
          nodes.add(_parseTable(content));
          break;
        case 'img':
          nodes.add(_parseImage(attrs));
          break;
        case 'hr':
          nodes.add(HorizontalRuleNode());
          break;
      }

      lastEnd = match.end;
    }

    // Handle remaining text
    if (lastEnd < cleanHtml.length) {
      final remaining = cleanHtml.substring(lastEnd).trim();
      if (remaining.isNotEmpty) {
        nodes.add(ParagraphNode.fromText(_stripHtml(remaining)));
      }
    }

    // If no nodes were parsed, create a single paragraph with the content
    if (nodes.isEmpty) {
      nodes.add(ParagraphNode.fromText(_stripHtml(cleanHtml)));
    }

    return Document(nodes);
  }

  ParagraphNode _parseParagraph(String content, String attrs, BlockType blockType) {
    final text = _parseInlineContent(content);
    final alignment = _parseAlignment(attrs);

    return ParagraphNode(
      text: text,
      blockType: blockType,
      alignment: alignment,
    );
  }

  TextAlign _parseAlignment(String attrs) {
    if (attrs.contains('text-align: center') || attrs.contains('text-align:center')) {
      return TextAlign.center;
    }
    if (attrs.contains('text-align: right') || attrs.contains('text-align:right')) {
      return TextAlign.right;
    }
    if (attrs.contains('text-align: justify') || attrs.contains('text-align:justify')) {
      return TextAlign.justify;
    }
    return TextAlign.left;
  }

  AttributedText _parseInlineContent(String content) {
    // Simple parsing: strip HTML tags for MVP
    // A proper implementation would preserve formatting
    final plainText = _stripHtml(content);
    return AttributedText.fromText(plainText);
  }

  CodeBlockNode _parseCodeBlock(String content, String attrs) {
    // Extract language from class attribute
    String? language;
    final langMatch = RegExp(r'class="language-(\w+)"').firstMatch(content);
    if (langMatch != null) {
      language = langMatch.group(1);
    }

    // Extract code from <code> tag if present
    final codeMatch = RegExp(r'<code[^>]*>(.*?)</code>', dotAll: true).firstMatch(content);
    final code = codeMatch != null ? _unescapeHtml(codeMatch.group(1) ?? '') : _unescapeHtml(content);

    return CodeBlockNode(code: code, language: language);
  }

  List<ListItemNode> _parseList(String content, ListType listType) {
    final items = <ListItemNode>[];

    final itemPattern = RegExp(r'<li[^>]*>(.*?)</li>', dotAll: true);
    for (final match in itemPattern.allMatches(content)) {
      final itemContent = match.group(1) ?? '';
      items.add(ListItemNode(
        text: _parseInlineContent(itemContent),
        listType: listType,
      ));
    }

    return items;
  }

  TableNode _parseTable(String content) {
    final rows = <List<TableCell>>[];
    bool hasHeader = false;

    // Check for thead
    if (content.contains('<thead>')) {
      hasHeader = true;
    }

    // Parse rows
    final rowPattern = RegExp(r'<tr[^>]*>(.*?)</tr>', dotAll: true);
    for (final rowMatch in rowPattern.allMatches(content)) {
      final rowContent = rowMatch.group(1) ?? '';
      final cells = <TableCell>[];

      // Parse cells (both th and td)
      final cellPattern = RegExp(r'<(th|td)[^>]*>(.*?)</\1>', dotAll: true);
      for (final cellMatch in cellPattern.allMatches(rowContent)) {
        final cellContent = cellMatch.group(2) ?? '';
        cells.add(TableCell(text: _parseInlineContent(cellContent)));
      }

      if (cells.isNotEmpty) {
        rows.add(cells);
      }
    }

    // Ensure at least one row and column
    if (rows.isEmpty) {
      rows.add([TableCell()]);
    }

    return TableNode(cells: rows, hasHeader: hasHeader);
  }

  ImageNode _parseImage(String attrs) {
    String src = '';
    String alt = '';
    double? width;
    double? height;

    // Parse src
    final srcMatch = RegExp(r'src="([^"]*)"').firstMatch(attrs);
    if (srcMatch != null) {
      src = _unescapeHtml(srcMatch.group(1) ?? '');
    }

    // Parse alt
    final altMatch = RegExp(r'alt="([^"]*)"').firstMatch(attrs);
    if (altMatch != null) {
      alt = _unescapeHtml(altMatch.group(1) ?? '');
    }

    // Parse width
    final widthMatch = RegExp(r'width="(\d+)"').firstMatch(attrs);
    if (widthMatch != null) {
      width = double.tryParse(widthMatch.group(1) ?? '');
    }

    // Parse height
    final heightMatch = RegExp(r'height="(\d+)"').firstMatch(attrs);
    if (heightMatch != null) {
      height = double.tryParse(heightMatch.group(1) ?? '');
    }

    return ImageNode(src: src, alt: alt, width: width, height: height);
  }

  String _stripHtml(String html) {
    // Remove HTML tags
    var text = html.replaceAll(RegExp(r'<[^>]*>'), '');
    // Unescape HTML entities
    text = _unescapeHtml(text);
    // Normalize whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  String _unescapeHtml(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('<br>', '\n')
        .replaceAll('<br/>', '\n')
        .replaceAll('<br />', '\n');
  }
}
