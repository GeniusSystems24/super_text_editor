import 'package:flutter/material.dart';
import '../enums/list_type.dart';
import '../enums/paragraph_type.dart';
import '../enums/text_alignment.dart';
import 'text_style_model.dart';

/// Base class for all editor nodes
abstract class EditorNode {
  /// Unique identifier for this node
  final String id;

  /// Creates a new EditorNode
  EditorNode({String? id}) : id = id ?? UniqueKey().toString();

  /// Converts this node to HTML
  String toHtml();

  /// Creates a copy of this node
  EditorNode copyWith();
}

/// Represents a span of text with consistent styling
class TextSpanNode extends EditorNode {
  /// The text content
  final String text;

  /// The style applied to this text
  final TextStyleModel style;

  /// Creates a new TextSpanNode
  TextSpanNode({
    super.id,
    required this.text,
    TextStyleModel? style,
  }) : style = style ?? TextStyleModel.empty();

  @override
  String toHtml() {
    if (text.isEmpty) return '';

    String html = _escapeHtml(text);

    // Apply formatting tags
    if (style.isBold) html = '<strong>$html</strong>';
    if (style.isItalic) html = '<em>$html</em>';
    if (style.isUnderline) html = '<u>$html</u>';
    if (style.isStrikethrough) html = '<s>$html</s>';
    if (style.isSubscript) html = '<sub>$html</sub>';
    if (style.isSuperscript) html = '<sup>$html</sup>';
    if (style.isCode) html = '<code>$html</code>';

    // Apply inline styles
    final styles = <String>[];
    if (style.textColor != null) {
      styles.add('color: ${_colorToHex(style.textColor!)}');
    }
    if (style.backgroundColor != null) {
      styles.add('background-color: ${_colorToHex(style.backgroundColor!)}');
    }
    if (style.fontSize != null) {
      styles.add('font-size: ${style.fontSize}px');
    }

    if (styles.isNotEmpty) {
      html = '<span style="${styles.join('; ')}">$html</span>';
    }

    return html;
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).padLeft(6, '0')}';
  }

  @override
  TextSpanNode copyWith({
    String? id,
    String? text,
    TextStyleModel? style,
  }) {
    return TextSpanNode(
      id: id ?? this.id,
      text: text ?? this.text,
      style: style ?? this.style,
    );
  }
}

/// Represents a paragraph or block-level element
class ParagraphNode extends EditorNode {
  /// The paragraph type (heading, quote, etc.)
  final ParagraphType type;

  /// Text alignment
  final TextAlignment alignment;

  /// Child text spans
  final List<TextSpanNode> children;

  /// Indentation level (0-based)
  final int indentLevel;

  /// Creates a new ParagraphNode
  ParagraphNode({
    super.id,
    this.type = ParagraphType.paragraph,
    this.alignment = TextAlignment.left,
    List<TextSpanNode>? children,
    this.indentLevel = 0,
  }) : children = children ?? [];

  /// Returns the plain text content of this paragraph
  String get plainText => children.map((c) => c.text).join();

  /// Returns true if this paragraph is empty
  bool get isEmpty => children.isEmpty || plainText.isEmpty;

  @override
  String toHtml() {
    final tag = type.htmlTag;
    final childrenHtml = children.map((c) => c.toHtml()).join();

    final styles = <String>[];
    if (alignment != TextAlignment.left) {
      styles.add('text-align: ${alignment.name}');
    }
    if (indentLevel > 0) {
      styles.add('margin-left: ${indentLevel * 40}px');
    }

    final styleAttr = styles.isNotEmpty ? ' style="${styles.join('; ')}"' : '';

    if (childrenHtml.isEmpty) {
      return '<$tag$styleAttr><br></$tag>';
    }

    return '<$tag$styleAttr>$childrenHtml</$tag>';
  }

  @override
  ParagraphNode copyWith({
    String? id,
    ParagraphType? type,
    TextAlignment? alignment,
    List<TextSpanNode>? children,
    int? indentLevel,
  }) {
    return ParagraphNode(
      id: id ?? this.id,
      type: type ?? this.type,
      alignment: alignment ?? this.alignment,
      children: children ?? List.from(this.children),
      indentLevel: indentLevel ?? this.indentLevel,
    );
  }
}

/// Represents a list item
class ListItemNode extends EditorNode {
  /// Child text spans
  final List<TextSpanNode> children;

  /// Creates a new ListItemNode
  ListItemNode({
    super.id,
    List<TextSpanNode>? children,
  }) : children = children ?? [];

  /// Returns the plain text content
  String get plainText => children.map((c) => c.text).join();

  @override
  String toHtml() {
    final childrenHtml = children.map((c) => c.toHtml()).join();
    return '<li>$childrenHtml</li>';
  }

  @override
  ListItemNode copyWith({
    String? id,
    List<TextSpanNode>? children,
  }) {
    return ListItemNode(
      id: id ?? this.id,
      children: children ?? List.from(this.children),
    );
  }
}

/// Represents a list (ordered or unordered)
class ListNode extends EditorNode {
  /// The list type
  final ListType listType;

  /// List items
  final List<ListItemNode> items;

  /// Creates a new ListNode
  ListNode({
    super.id,
    this.listType = ListType.bullet,
    List<ListItemNode>? items,
  }) : items = items ?? [];

  @override
  String toHtml() {
    final tag = listType.htmlTag;
    final itemsHtml = items.map((i) => i.toHtml()).join('\n');

    final styleAttr =
        listType != ListType.bullet && listType != ListType.decimal
            ? ' style="list-style-type: ${listType.cssValue}"'
            : '';

    return '<$tag$styleAttr>\n$itemsHtml\n</$tag>';
  }

  @override
  ListNode copyWith({
    String? id,
    ListType? listType,
    List<ListItemNode>? items,
  }) {
    return ListNode(
      id: id ?? this.id,
      listType: listType ?? this.listType,
      items: items ?? List.from(this.items),
    );
  }
}

/// Represents a table cell
class TableCellNode extends EditorNode {
  /// Cell content
  final List<TextSpanNode> children;

  /// Whether this is a header cell
  final bool isHeader;

  /// Column span
  final int colSpan;

  /// Row span
  final int rowSpan;

  /// Creates a new TableCellNode
  TableCellNode({
    super.id,
    List<TextSpanNode>? children,
    this.isHeader = false,
    this.colSpan = 1,
    this.rowSpan = 1,
  }) : children = children ?? [];

  @override
  String toHtml() {
    final tag = isHeader ? 'th' : 'td';
    final childrenHtml = children.map((c) => c.toHtml()).join();

    final attrs = <String>[];
    if (colSpan > 1) attrs.add('colspan="$colSpan"');
    if (rowSpan > 1) attrs.add('rowspan="$rowSpan"');
    final attrStr = attrs.isNotEmpty ? ' ${attrs.join(' ')}' : '';

    return '<$tag$attrStr>$childrenHtml</$tag>';
  }

  @override
  TableCellNode copyWith({
    String? id,
    List<TextSpanNode>? children,
    bool? isHeader,
    int? colSpan,
    int? rowSpan,
  }) {
    return TableCellNode(
      id: id ?? this.id,
      children: children ?? List.from(this.children),
      isHeader: isHeader ?? this.isHeader,
      colSpan: colSpan ?? this.colSpan,
      rowSpan: rowSpan ?? this.rowSpan,
    );
  }
}

/// Represents a table row
class TableRowNode extends EditorNode {
  /// Row cells
  final List<TableCellNode> cells;

  /// Creates a new TableRowNode
  TableRowNode({
    super.id,
    List<TableCellNode>? cells,
  }) : cells = cells ?? [];

  @override
  String toHtml() {
    final cellsHtml = cells.map((c) => c.toHtml()).join('\n');
    return '<tr>\n$cellsHtml\n</tr>';
  }

  @override
  TableRowNode copyWith({
    String? id,
    List<TableCellNode>? cells,
  }) {
    return TableRowNode(
      id: id ?? this.id,
      cells: cells ?? List.from(this.cells),
    );
  }
}

/// Represents a table
class TableNode extends EditorNode {
  /// Table rows
  final List<TableRowNode> rows;

  /// Whether the first row is a header
  final bool hasHeader;

  /// Creates a new TableNode
  TableNode({
    super.id,
    List<TableRowNode>? rows,
    this.hasHeader = true,
  }) : rows = rows ?? [];

  @override
  String toHtml() {
    if (rows.isEmpty) return '<table></table>';

    final buffer = StringBuffer('<table>\n');

    if (hasHeader && rows.isNotEmpty) {
      buffer.writeln('<thead>');
      buffer.writeln(rows.first.toHtml());
      buffer.writeln('</thead>');

      if (rows.length > 1) {
        buffer.writeln('<tbody>');
        for (int i = 1; i < rows.length; i++) {
          buffer.writeln(rows[i].toHtml());
        }
        buffer.writeln('</tbody>');
      }
    } else {
      buffer.writeln('<tbody>');
      for (final row in rows) {
        buffer.writeln(row.toHtml());
      }
      buffer.writeln('</tbody>');
    }

    buffer.write('</table>');
    return buffer.toString();
  }

  @override
  TableNode copyWith({
    String? id,
    List<TableRowNode>? rows,
    bool? hasHeader,
  }) {
    return TableNode(
      id: id ?? this.id,
      rows: rows ?? List.from(this.rows),
      hasHeader: hasHeader ?? this.hasHeader,
    );
  }
}

/// Represents a horizontal rule
class HorizontalRuleNode extends EditorNode {
  /// Creates a new HorizontalRuleNode
  HorizontalRuleNode({super.id});

  @override
  String toHtml() => '<hr>';

  @override
  HorizontalRuleNode copyWith({String? id}) {
    return HorizontalRuleNode(id: id ?? this.id);
  }
}

/// Represents an image
class ImageNode extends EditorNode {
  /// Image source URL
  final String src;

  /// Alt text
  final String alt;

  /// Width in pixels (null for auto)
  final double? width;

  /// Height in pixels (null for auto)
  final double? height;

  /// Creates a new ImageNode
  ImageNode({
    super.id,
    required this.src,
    this.alt = '',
    this.width,
    this.height,
  });

  @override
  String toHtml() {
    final attrs = <String>['src="$src"', 'alt="$alt"'];
    if (width != null) attrs.add('width="${width!.toInt()}"');
    if (height != null) attrs.add('height="${height!.toInt()}"');
    return '<img ${attrs.join(' ')}>';
  }

  @override
  ImageNode copyWith({
    String? id,
    String? src,
    String? alt,
    double? width,
    double? height,
  }) {
    return ImageNode(
      id: id ?? this.id,
      src: src ?? this.src,
      alt: alt ?? this.alt,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

/// Represents a link
class LinkNode extends EditorNode {
  /// Link URL
  final String href;

  /// Link text
  final String text;

  /// Whether to open in new tab
  final bool openInNewTab;

  /// Creates a new LinkNode
  LinkNode({
    super.id,
    required this.href,
    required this.text,
    this.openInNewTab = true,
  });

  @override
  String toHtml() {
    final target = openInNewTab ? ' target="_blank" rel="noopener"' : '';
    return '<a href="$href"$target>$text</a>';
  }

  @override
  LinkNode copyWith({
    String? id,
    String? href,
    String? text,
    bool? openInNewTab,
  }) {
    return LinkNode(
      id: id ?? this.id,
      href: href ?? this.href,
      text: text ?? this.text,
      openInNewTab: openInNewTab ?? this.openInNewTab,
    );
  }
}

/// Represents a code block
class CodeBlockNode extends EditorNode {
  /// The code content
  final String code;

  /// The programming language
  final String? language;

  /// Creates a new CodeBlockNode
  CodeBlockNode({
    super.id,
    required this.code,
    this.language,
  });

  @override
  String toHtml() {
    final escapedCode = code
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');

    final langClass = language != null ? ' class="language-$language"' : '';
    return '<pre><code$langClass>$escapedCode</code></pre>';
  }

  @override
  CodeBlockNode copyWith({
    String? id,
    String? code,
    String? language,
  }) {
    return CodeBlockNode(
      id: id ?? this.id,
      code: code ?? this.code,
      language: language ?? this.language,
    );
  }
}
