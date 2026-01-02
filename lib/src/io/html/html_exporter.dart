import '../../core/document/document.dart';
import '../../core/document/nodes.dart';
import '../../core/document/attributed_text.dart';

/// Exports a document to HTML
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
    ListType? currentListType;
    int listStartIndex = -1;

    for (int i = 0; i < document.length; i++) {
      final node = document.getNodeAt(i);

      // Handle list grouping
      if (node is ListItemNode) {
        if (currentListType != node.listType) {
          // Close previous list if any
          if (currentListType != null) {
            buffer.writeln(_closeListTag(currentListType));
          }
          // Open new list
          currentListType = node.listType;
          listStartIndex = 1;
          buffer.writeln(_openListTag(currentListType));
        }
        buffer.writeln(_exportListItem(node, listStartIndex++));
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
    } else if (node is TableNode) {
      return _exportTable(node);
    } else if (node is ImageNode) {
      return _exportImage(node);
    } else if (node is HorizontalRuleNode) {
      return '<hr>';
    } else if (node is CodeBlockNode) {
      return _exportCodeBlock(node);
    }
    return '';
  }

  String _exportParagraph(ParagraphNode node) {
    final tag = _getBlockTag(node.blockType);
    final styles = <String>[];

    if (includeStyles) {
      if (node.alignment != TextAlign.left) {
        styles.add('text-align: ${_alignmentToCss(node.alignment)}');
      }
      if (node.indentLevel > 0) {
        styles.add('margin-left: ${node.indentLevel * 40}px');
      }
    }

    final styleAttr = styles.isNotEmpty ? ' style="${styles.join('; ')}"' : '';
    final content = _exportAttributedText(node.text);

    if (content.isEmpty) {
      return '<$tag$styleAttr><br></$tag>';
    }

    return '<$tag$styleAttr>$content</$tag>';
  }

  String _getBlockTag(BlockType blockType) {
    switch (blockType) {
      case BlockType.heading1:
        return 'h1';
      case BlockType.heading2:
        return 'h2';
      case BlockType.heading3:
        return 'h3';
      case BlockType.heading4:
        return 'h4';
      case BlockType.heading5:
        return 'h5';
      case BlockType.heading6:
        return 'h6';
      case BlockType.blockquote:
        return 'blockquote';
      case BlockType.preformatted:
        return 'pre';
      case BlockType.paragraph:
      default:
        return 'p';
    }
  }

  String _alignmentToCss(TextAlign alignment) {
    switch (alignment) {
      case TextAlign.center:
        return 'center';
      case TextAlign.right:
        return 'right';
      case TextAlign.justify:
        return 'justify';
      case TextAlign.left:
      default:
        return 'left';
    }
  }

  String _exportAttributedText(AttributedText text) {
    if (text.isEmpty) return '';

    // Simple export - just escape and wrap with formatting tags
    // A more sophisticated implementation would handle spans properly
    final buffer = StringBuffer();
    final escapedText = _escapeHtml(text.text);

    // For now, just output the plain text
    // TODO: Implement proper span-based HTML export
    if (text.spans.isEmpty) {
      return escapedText;
    }

    // Simple approach: output text with inline formatting
    int lastEnd = 0;
    for (final span in text.spans) {
      // Add text before this span
      if (span.start > lastEnd) {
        buffer.write(_escapeHtml(text.text.substring(lastEnd, span.start)));
      }

      // Add formatted text
      final spanText = _escapeHtml(text.text.substring(span.start, span.end));
      buffer.write(_wrapWithFormatting(spanText, span.attributes));

      lastEnd = span.end;
    }

    // Add remaining text
    if (lastEnd < text.text.length) {
      buffer.write(_escapeHtml(text.text.substring(lastEnd)));
    }

    return buffer.toString();
  }

  String _wrapWithFormatting(String text, TextAttributes attrs) {
    var result = text;

    if (attrs.bold) result = '<strong>$result</strong>';
    if (attrs.italic) result = '<em>$result</em>';
    if (attrs.underline) result = '<u>$result</u>';
    if (attrs.strikethrough) result = '<s>$result</s>';
    if (attrs.subscript) result = '<sub>$result</sub>';
    if (attrs.superscript) result = '<sup>$result</sup>';
    if (attrs.code) result = '<code>$result</code>';

    if (attrs.linkUrl != null) {
      result = '<a href="${_escapeAttr(attrs.linkUrl!)}" target="_blank">$result</a>';
    }

    // Inline styles
    final styles = <String>[];
    if (attrs.textColor != null) {
      styles.add('color: ${_colorToHex(attrs.textColor!.value)}');
    }
    if (attrs.backgroundColor != null) {
      styles.add('background-color: ${_colorToHex(attrs.backgroundColor!.value)}');
    }
    if (attrs.fontSize != null) {
      styles.add('font-size: ${attrs.fontSize}px');
    }
    if (attrs.fontFamily != null) {
      styles.add('font-family: ${attrs.fontFamily}');
    }

    if (styles.isNotEmpty) {
      result = '<span style="${styles.join('; ')}">$result</span>';
    }

    return result;
  }

  String _openListTag(ListType listType) {
    return listType == ListType.numbered ? '<ol>' : '<ul>';
  }

  String _closeListTag(ListType listType) {
    return listType == ListType.numbered ? '</ol>' : '</ul>';
  }

  String _exportListItem(ListItemNode node, int index) {
    final content = _exportAttributedText(node.text);
    return '<li>$content</li>';
  }

  String _exportTable(TableNode node) {
    final buffer = StringBuffer('<table');

    if (includeStyles && node.style.showBorders) {
      buffer.write(' border="1"');
    }

    buffer.writeln('>');

    for (int rowIndex = 0; rowIndex < node.rowCount; rowIndex++) {
      final isHeader = rowIndex == 0 && node.hasHeader;

      if (isHeader) {
        buffer.writeln('<thead>');
      } else if (rowIndex == 1 && node.hasHeader) {
        buffer.writeln('<tbody>');
      } else if (rowIndex == 0) {
        buffer.writeln('<tbody>');
      }

      buffer.writeln('<tr>');

      for (int colIndex = 0; colIndex < node.columnCount; colIndex++) {
        final cell = node.getCell(rowIndex, colIndex);
        final tag = isHeader ? 'th' : 'td';
        final content = _exportAttributedText(cell.text);

        final styles = <String>[];
        if (includeStyles) {
          if (cell.alignment != TextAlign.left) {
            styles.add('text-align: ${_alignmentToCss(cell.alignment)}');
          }
          if (cell.backgroundColor != null) {
            styles.add('background-color: ${_colorToHex(cell.backgroundColor!)}');
          }
        }

        final styleAttr = styles.isNotEmpty ? ' style="${styles.join('; ')}"' : '';
        buffer.writeln('<$tag$styleAttr>$content</$tag>');
      }

      buffer.writeln('</tr>');

      if (isHeader) {
        buffer.writeln('</thead>');
      }
    }

    if (node.rowCount > 0) {
      if (!node.hasHeader || node.rowCount > 1) {
        buffer.writeln('</tbody>');
      }
    }

    buffer.write('</table>');
    return buffer.toString();
  }

  String _exportImage(ImageNode node) {
    final attrs = <String>['src="${_escapeAttr(node.src)}"'];

    if (node.alt.isNotEmpty) {
      attrs.add('alt="${_escapeAttr(node.alt)}"');
    }
    if (node.width != null) {
      attrs.add('width="${node.width!.toInt()}"');
    }
    if (node.height != null) {
      attrs.add('height="${node.height!.toInt()}"');
    }

    return '<img ${attrs.join(' ')}>';
  }

  String _exportCodeBlock(CodeBlockNode node) {
    final escapedCode = _escapeHtml(node.code);
    final langClass = node.language != null ? ' class="language-${node.language}"' : '';
    return '<pre><code$langClass>$escapedCode</code></pre>';
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

  String _colorToHex(int colorValue) {
    return '#${(colorValue & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }
}
