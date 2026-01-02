import 'package:super_editor/super_editor.dart';

/// Exports a super_editor document to HTML
class HtmlExporter {
  /// Whether to include inline styles
  final bool includeStyles;

  /// Whether to format the output with indentation
  final bool prettyPrint;

  /// Creates a new HTML exporter
  const HtmlExporter({
    this.includeStyles = true,
    this.prettyPrint = true,
  });

  /// Exports a document to HTML
  String export(Document document) {
    final buffer = StringBuffer();

    // Track list grouping
    ListItemType? currentListType;

    for (int i = 0; i < document.nodeCount; i++) {
      final node = document.getNodeAt(i);

      // Handle list grouping
      if (node is ListItemNode) {
        if (currentListType != node.type) {
          // Close previous list if any
          if (currentListType != null) {
            buffer.writeln(_closeListTag(currentListType));
          }
          // Open new list
          currentListType = node.type;
          buffer.writeln(_openListTag(currentListType));
        }
        buffer.writeln(_exportListItem(node));
      } else {
        // Close list if we were in one
        if (currentListType != null) {
          buffer.writeln(_closeListTag(currentListType));
          currentListType = null;
        }
        buffer.writeln(_exportNode(node));
      }
    }

    // Close any remaining list
    if (currentListType != null) {
      buffer.writeln(_closeListTag(currentListType));
    }

    return buffer.toString().trim();
  }

  String _exportNode(DocumentNode node) {
    if (node is ParagraphNode) {
      return _exportParagraph(node);
    } else if (node is ImageNode) {
      return _exportImage(node);
    } else if (node is HorizontalRuleNode) {
      return '<hr>';
    } else if (node is TaskNode) {
      return _exportTask(node);
    }
    return '';
  }

  String _exportParagraph(ParagraphNode node) {
    final blockType = node.metadata['blockType'];
    final tag = _getBlockTag(blockType);
    final content = _exportAttributedText(node.text);

    if (content.isEmpty) {
      return '<$tag><br></$tag>';
    }

    return '<$tag>$content</$tag>';
  }

  String _getBlockTag(Attribution? blockType) {
    if (blockType == header1Attribution) return 'h1';
    if (blockType == header2Attribution) return 'h2';
    if (blockType == header3Attribution) return 'h3';
    if (blockType == header4Attribution) return 'h4';
    if (blockType == header5Attribution) return 'h5';
    if (blockType == header6Attribution) return 'h6';
    if (blockType == blockquoteAttribution) return 'blockquote';
    if (blockType == codeAttribution) return 'pre';
    return 'p';
  }

  String _exportAttributedText(AttributedText text) {
    if (text.text.isEmpty) return '';

    final buffer = StringBuffer();
    final plainText = text.text;

    // Get all attribution spans
    final spans = text.getAttributionSpansInRange(
      attributionFilter: (a) => true,
      range: SpanRange(0, plainText.length - 1),
    );

    if (spans.isEmpty) {
      return _escapeHtml(plainText);
    }

    // Simple approach: process character by character
    int i = 0;
    while (i < plainText.length) {
      final attributions = text.getAllAttributionsAt(i);

      // Find the end of this span (where attributions change)
      int end = i + 1;
      while (end < plainText.length) {
        final nextAttributions = text.getAllAttributionsAt(end);
        if (!_sameAttributions(attributions, nextAttributions)) break;
        end++;
      }

      final segment = _escapeHtml(plainText.substring(i, end));
      buffer.write(_wrapWithFormatting(segment, attributions));
      i = end;
    }

    return buffer.toString();
  }

  bool _sameAttributions(Set<Attribution> a, Set<Attribution> b) {
    if (a.length != b.length) return false;
    for (final attr in a) {
      if (!b.contains(attr)) return false;
    }
    return true;
  }

  String _wrapWithFormatting(String text, Set<Attribution> attributions) {
    var result = text;

    if (attributions.contains(boldAttribution)) {
      result = '<strong>$result</strong>';
    }
    if (attributions.contains(italicsAttribution)) {
      result = '<em>$result</em>';
    }
    if (attributions.contains(underlineAttribution)) {
      result = '<u>$result</u>';
    }
    if (attributions.contains(strikethroughAttribution)) {
      result = '<s>$result</s>';
    }

    // Handle link attribution
    for (final attr in attributions) {
      if (attr is LinkAttribution) {
        result = '<a href="${_escapeAttr(attr.url.toString())}" target="_blank">$result</a>';
        break;
      }
    }

    return result;
  }

  String _openListTag(ListItemType listType) {
    return listType == ListItemType.ordered ? '<ol>' : '<ul>';
  }

  String _closeListTag(ListItemType listType) {
    return listType == ListItemType.ordered ? '</ol>' : '</ul>';
  }

  String _exportListItem(ListItemNode node) {
    final content = _exportAttributedText(node.text);
    return '<li>$content</li>';
  }

  String _exportTask(TaskNode node) {
    final content = _exportAttributedText(node.text);
    final checked = node.isComplete ? ' checked' : '';
    return '<div class="task"><input type="checkbox"$checked disabled> $content</div>';
  }

  String _exportImage(ImageNode node) {
    final attrs = <String>['src="${_escapeAttr(node.imageUrl)}"'];

    if (node.altText.isNotEmpty) {
      attrs.add('alt="${_escapeAttr(node.altText)}"');
    }

    return '<img ${attrs.join(' ')}>';
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }

  String _escapeAttr(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
