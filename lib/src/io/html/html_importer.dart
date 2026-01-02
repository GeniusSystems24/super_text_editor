import 'package:super_editor/super_editor.dart';

/// Imports HTML into a super_editor document
class HtmlImporter {
  /// Creates a new HTML importer
  const HtmlImporter();

  /// Imports HTML and returns a MutableDocument
  MutableDocument import(String html) {
    final nodes = <DocumentNode>[];

    // Simple regex-based parsing
    final cleanHtml = html.trim();

    // Parse block elements
    final blockPattern = RegExp(
      r'<(p|h[1-6]|blockquote|pre|ul|ol|img|hr)([^>]*)>(.*?)</\1>|<(img|hr)([^>]*)/?>'
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
          nodes.add(ParagraphNode(
            id: Editor.createNodeId(),
            text: AttributedText(_stripHtml(textBetween)),
          ));
        }
      }

      final tag = match.group(1) ?? match.group(4) ?? match.group(6);
      final content = match.group(3) ?? match.group(8) ?? '';

      switch (tag?.toLowerCase()) {
        case 'p':
          nodes.add(_createParagraph(content, null));
          break;
        case 'h1':
          nodes.add(_createParagraph(content, header1Attribution));
          break;
        case 'h2':
          nodes.add(_createParagraph(content, header2Attribution));
          break;
        case 'h3':
          nodes.add(_createParagraph(content, header3Attribution));
          break;
        case 'h4':
          nodes.add(_createParagraph(content, header4Attribution));
          break;
        case 'h5':
          nodes.add(_createParagraph(content, header5Attribution));
          break;
        case 'h6':
          nodes.add(_createParagraph(content, header6Attribution));
          break;
        case 'blockquote':
          nodes.add(_createParagraph(content, blockquoteAttribution));
          break;
        case 'pre':
          nodes.add(_createParagraph(content, codeAttribution));
          break;
        case 'ul':
          nodes.addAll(_parseList(content, ListItemType.unordered));
          break;
        case 'ol':
          nodes.addAll(_parseList(content, ListItemType.ordered));
          break;
        case 'img':
          final attrs = match.group(2) ?? match.group(5) ?? '';
          nodes.add(_parseImage(attrs));
          break;
        case 'hr':
          nodes.add(HorizontalRuleNode(id: Editor.createNodeId()));
          break;
      }

      lastEnd = match.end;
    }

    // Handle remaining text
    if (lastEnd < cleanHtml.length) {
      final remaining = cleanHtml.substring(lastEnd).trim();
      if (remaining.isNotEmpty) {
        nodes.add(ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(_stripHtml(remaining)),
        ));
      }
    }

    // If no nodes were parsed, create a single paragraph with the content
    if (nodes.isEmpty) {
      nodes.add(ParagraphNode(
        id: Editor.createNodeId(),
        text: AttributedText(_stripHtml(cleanHtml)),
      ));
    }

    return MutableDocument(nodes: nodes);
  }

  ParagraphNode _createParagraph(String content, Attribution? blockType) {
    final text = _parseInlineContent(content);
    return ParagraphNode(
      id: Editor.createNodeId(),
      text: text,
      metadata: blockType != null ? {'blockType': blockType} : {},
    );
  }

  AttributedText _parseInlineContent(String content) {
    // Simple parsing: strip HTML tags for MVP
    final plainText = _stripHtml(content);
    return AttributedText(plainText);
  }

  List<ListItemNode> _parseList(String content, ListItemType listType) {
    final items = <ListItemNode>[];

    final itemPattern = RegExp(r'<li[^>]*>(.*?)</li>', dotAll: true);
    for (final match in itemPattern.allMatches(content)) {
      final itemContent = match.group(1) ?? '';
      items.add(ListItemNode(
        id: Editor.createNodeId(),
        itemType: listType,
        text: _parseInlineContent(itemContent),
      ));
    }

    return items;
  }

  ImageNode _parseImage(String attrs) {
    String src = '';
    String alt = '';

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

    return ImageNode(
      id: Editor.createNodeId(),
      imageUrl: src,
      altText: alt,
    );
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
