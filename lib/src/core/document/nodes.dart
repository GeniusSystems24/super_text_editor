import 'dart:ui' show TextAlign;
import 'document.dart';
import 'attributed_text.dart';

export 'dart:ui' show TextAlign;

/// Block style for paragraphs
enum BlockType {
  paragraph,
  heading1,
  heading2,
  heading3,
  heading4,
  heading5,
  heading6,
  blockquote,
  preformatted,
}

/// List type
enum ListType {
  bullet,
  numbered;

  /// Whether this is an ordered list type
  bool get isOrdered => this == ListType.numbered;
}

/// Base class for all document nodes
abstract class DocumentNode {
  /// Unique identifier for this node
  final String id;

  /// Creates a new document node
  DocumentNode({String? id}) : id = id ?? generateNodeId();

  /// Whether this node is empty
  bool get isEmpty;

  /// Gets the plain text content of this node
  String get plainText;

  /// Converts this node to JSON
  Map<String, dynamic> toJson();

  /// Creates a node from JSON
  static DocumentNode fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'paragraph':
        return ParagraphNode.fromJson(json);
      case 'listItem':
        return ListItemNode.fromJson(json);
      case 'table':
        return TableNode.fromJson(json);
      case 'image':
        return ImageNode.fromJson(json);
      case 'horizontalRule':
        return HorizontalRuleNode.fromJson(json);
      case 'codeBlock':
        return CodeBlockNode.fromJson(json);
      default:
        // Fallback to paragraph
        return ParagraphNode();
    }
  }

  /// Creates a deep copy of this node
  DocumentNode copy();
}

/// A paragraph node with attributed text
class ParagraphNode extends DocumentNode {
  /// The attributed text content
  AttributedText text;

  /// Text alignment
  TextAlign alignment;

  /// Block type (heading, paragraph, etc.)
  BlockType blockType;

  /// Indentation level
  int indentLevel;

  /// Creates a new paragraph node
  ParagraphNode({
    super.id,
    AttributedText? text,
    this.alignment = TextAlign.left,
    this.blockType = BlockType.paragraph,
    this.indentLevel = 0,
  }) : text = text ?? AttributedText.empty;

  /// Creates a paragraph from plain text
  factory ParagraphNode.fromText(String text, {
    TextAlign alignment = TextAlign.left,
    BlockType blockType = BlockType.paragraph,
    int indentLevel = 0,
  }) {
    return ParagraphNode(
      text: AttributedText.fromText(text),
      alignment: alignment,
      blockType: blockType,
      indentLevel: indentLevel,
    );
  }

  @override
  bool get isEmpty => text.isEmpty;

  @override
  String get plainText => text.text;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'paragraph',
      'id': id,
      'text': text.toJson(),
      'alignment': alignment.name,
      'blockType': blockType.name,
      'indentLevel': indentLevel,
    };
  }

  factory ParagraphNode.fromJson(Map<String, dynamic> json) {
    return ParagraphNode(
      id: json['id'] as String?,
      text: json['text'] != null
          ? AttributedText.fromJson(json['text'] as Map<String, dynamic>)
          : null,
      alignment: TextAlign.values.firstWhere(
        (e) => e.name == json['alignment'],
        orElse: () => TextAlign.left,
      ),
      blockType: BlockType.values.firstWhere(
        (e) => e.name == json['blockType'],
        orElse: () => BlockType.paragraph,
      ),
      indentLevel: json['indentLevel'] as int? ?? 0,
    );
  }

  @override
  ParagraphNode copy() {
    return ParagraphNode(
      id: id,
      text: text.copyWith(),
      alignment: alignment,
      blockType: blockType,
      indentLevel: indentLevel,
    );
  }
}

/// A list item node
class ListItemNode extends DocumentNode {
  /// The attributed text content
  AttributedText text;

  /// List type (bullet or numbered)
  ListType listType;

  /// Indentation level
  int indentLevel;

  /// Creates a new list item node
  ListItemNode({
    super.id,
    AttributedText? text,
    this.listType = ListType.bullet,
    this.indentLevel = 0,
  }) : text = text ?? AttributedText.empty;

  /// Creates a list item from plain text
  factory ListItemNode.fromText(String text, {
    ListType listType = ListType.bullet,
    int indentLevel = 0,
  }) {
    return ListItemNode(
      text: AttributedText.fromText(text),
      listType: listType,
      indentLevel: indentLevel,
    );
  }

  @override
  bool get isEmpty => text.isEmpty;

  @override
  String get plainText => text.text;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'listItem',
      'id': id,
      'text': text.toJson(),
      'listType': listType.name,
      'indentLevel': indentLevel,
    };
  }

  factory ListItemNode.fromJson(Map<String, dynamic> json) {
    return ListItemNode(
      id: json['id'] as String?,
      text: json['text'] != null
          ? AttributedText.fromJson(json['text'] as Map<String, dynamic>)
          : null,
      listType: ListType.values.firstWhere(
        (e) => e.name == json['listType'],
        orElse: () => ListType.bullet,
      ),
      indentLevel: json['indentLevel'] as int? ?? 0,
    );
  }

  @override
  ListItemNode copy() {
    return ListItemNode(
      id: id,
      text: text.copyWith(),
      listType: listType,
      indentLevel: indentLevel,
    );
  }
}

/// A table cell
class TableCell {
  /// The attributed text content
  AttributedText text;

  /// Background color
  final int? backgroundColor;

  /// Text alignment
  final TextAlign alignment;

  /// Creates a new table cell
  TableCell({
    AttributedText? text,
    this.backgroundColor,
    this.alignment = TextAlign.left,
  }) : text = text ?? AttributedText.empty;

  /// Creates a table cell from plain text
  factory TableCell.fromText(String text) {
    return TableCell(text: AttributedText.fromText(text));
  }

  /// Whether this cell is empty
  bool get isEmpty => text.isEmpty;

  /// Gets the plain text content
  String get plainText => text.text;

  Map<String, dynamic> toJson() {
    return {
      'text': text.toJson(),
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
      'alignment': alignment.name,
    };
  }

  factory TableCell.fromJson(Map<String, dynamic> json) {
    return TableCell(
      text: json['text'] != null
          ? AttributedText.fromJson(json['text'] as Map<String, dynamic>)
          : null,
      backgroundColor: json['backgroundColor'] as int?,
      alignment: TextAlign.values.firstWhere(
        (e) => e.name == json['alignment'],
        orElse: () => TextAlign.left,
      ),
    );
  }

  TableCell copy() {
    return TableCell(
      text: text.copyWith(),
      backgroundColor: backgroundColor,
      alignment: alignment,
    );
  }
}

/// Table style configuration
class TableStyle {
  /// Whether to show borders
  final bool showBorders;

  /// Border color
  final int borderColor;

  /// Cell padding
  final double cellPadding;

  /// Header background color
  final int? headerBackgroundColor;

  /// Column widths (null for auto)
  final List<double?>? columnWidths;

  const TableStyle({
    this.showBorders = true,
    this.borderColor = 0xFFE0E0E0,
    this.cellPadding = 8.0,
    this.headerBackgroundColor,
    this.columnWidths,
  });

  Map<String, dynamic> toJson() {
    return {
      'showBorders': showBorders,
      'borderColor': borderColor,
      'cellPadding': cellPadding,
      if (headerBackgroundColor != null) 'headerBackgroundColor': headerBackgroundColor,
      if (columnWidths != null) 'columnWidths': columnWidths,
    };
  }

  factory TableStyle.fromJson(Map<String, dynamic> json) {
    return TableStyle(
      showBorders: json['showBorders'] as bool? ?? true,
      borderColor: json['borderColor'] as int? ?? 0xFFE0E0E0,
      cellPadding: (json['cellPadding'] as num?)?.toDouble() ?? 8.0,
      headerBackgroundColor: json['headerBackgroundColor'] as int?,
      columnWidths: (json['columnWidths'] as List<dynamic>?)
          ?.map((e) => e as double?)
          .toList(),
    );
  }
}

/// A table node
class TableNode extends DocumentNode {
  /// Number of rows
  int get rowCount => cells.length;

  /// Number of columns
  int get columnCount => cells.isEmpty ? 0 : cells.first.length;

  /// The cells in this table (row-major order)
  final List<List<TableCell>> cells;

  /// Whether the first row is a header
  bool hasHeader;

  /// Table style
  TableStyle style;

  /// Creates a new table node
  TableNode({
    super.id,
    required this.cells,
    this.hasHeader = true,
    this.style = const TableStyle(),
  });

  /// Creates a table with the given dimensions
  factory TableNode.withSize(int rows, int columns, {bool hasHeader = true}) {
    final cells = List.generate(
      rows,
      (_) => List.generate(columns, (_) => TableCell()),
    );
    return TableNode(cells: cells, hasHeader: hasHeader);
  }

  @override
  bool get isEmpty => cells.isEmpty || cells.every((row) => row.every((cell) => cell.isEmpty));

  @override
  String get plainText {
    return cells.map((row) => row.map((cell) => cell.plainText).join('\t')).join('\n');
  }

  /// Gets a cell at the given position
  TableCell getCell(int row, int col) {
    if (row < 0 || row >= rowCount || col < 0 || col >= columnCount) {
      throw RangeError('Cell position ($row, $col) is out of range');
    }
    return cells[row][col];
  }

  /// Sets a cell at the given position
  void setCell(int row, int col, TableCell cell) {
    if (row < 0 || row >= rowCount || col < 0 || col >= columnCount) {
      throw RangeError('Cell position ($row, $col) is out of range');
    }
    cells[row][col] = cell;
  }

  /// Inserts a row at the given index
  void insertRow(int index, [List<TableCell>? row]) {
    if (index < 0 || index > rowCount) {
      throw RangeError('Row index $index is out of range');
    }
    final newRow = row ?? List.generate(columnCount, (_) => TableCell());
    cells.insert(index, newRow);
  }

  /// Removes a row at the given index
  List<TableCell> removeRow(int index) {
    if (index < 0 || index >= rowCount) {
      throw RangeError('Row index $index is out of range');
    }
    return cells.removeAt(index);
  }

  /// Inserts a column at the given index
  void insertColumn(int index, [List<TableCell>? column]) {
    if (index < 0 || index > columnCount) {
      throw RangeError('Column index $index is out of range');
    }
    for (int i = 0; i < rowCount; i++) {
      cells[i].insert(index, column != null ? column[i] : TableCell());
    }
  }

  /// Removes a column at the given index
  List<TableCell> removeColumn(int index) {
    if (index < 0 || index >= columnCount) {
      throw RangeError('Column index $index is out of range');
    }
    return cells.map((row) => row.removeAt(index)).toList();
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'table',
      'id': id,
      'rows': rowCount,
      'cols': columnCount,
      'hasHeader': hasHeader,
      'cells': cells.map((row) => row.map((cell) => cell.toJson()).toList()).toList(),
      'style': style.toJson(),
    };
  }

  factory TableNode.fromJson(Map<String, dynamic> json) {
    final cellsJson = json['cells'] as List<dynamic>;
    final cells = cellsJson.map((row) {
      return (row as List<dynamic>).map((cell) {
        return TableCell.fromJson(cell as Map<String, dynamic>);
      }).toList();
    }).toList();

    return TableNode(
      id: json['id'] as String?,
      cells: cells,
      hasHeader: json['hasHeader'] as bool? ?? true,
      style: json['style'] != null
          ? TableStyle.fromJson(json['style'] as Map<String, dynamic>)
          : const TableStyle(),
    );
  }

  @override
  TableNode copy() {
    return TableNode(
      id: id,
      cells: cells.map((row) => row.map((cell) => cell.copy()).toList()).toList(),
      hasHeader: hasHeader,
      style: style,
    );
  }
}

/// An image node
class ImageNode extends DocumentNode {
  /// Image source URL
  final String src;

  /// Alt text
  final String alt;

  /// Width in pixels (null for auto)
  final double? width;

  /// Height in pixels (null for auto)
  final double? height;

  /// Text alignment
  final TextAlign alignment;

  /// Creates a new image node
  ImageNode({
    super.id,
    required this.src,
    this.alt = '',
    this.width,
    this.height,
    this.alignment = TextAlign.left,
  });

  @override
  bool get isEmpty => src.isEmpty;

  @override
  String get plainText => alt.isNotEmpty ? '[$alt]' : '[Image]';

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'image',
      'id': id,
      'src': src,
      'alt': alt,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      'alignment': alignment.name,
    };
  }

  factory ImageNode.fromJson(Map<String, dynamic> json) {
    return ImageNode(
      id: json['id'] as String?,
      src: json['src'] as String,
      alt: json['alt'] as String? ?? '',
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      alignment: TextAlign.values.firstWhere(
        (e) => e.name == json['alignment'],
        orElse: () => TextAlign.left,
      ),
    );
  }

  @override
  ImageNode copy() {
    return ImageNode(
      id: id,
      src: src,
      alt: alt,
      width: width,
      height: height,
      alignment: alignment,
    );
  }
}

/// A horizontal rule node
class HorizontalRuleNode extends DocumentNode {
  /// Creates a new horizontal rule node
  HorizontalRuleNode({super.id});

  @override
  bool get isEmpty => false;

  @override
  String get plainText => '---';

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'horizontalRule',
      'id': id,
    };
  }

  factory HorizontalRuleNode.fromJson(Map<String, dynamic> json) {
    return HorizontalRuleNode(id: json['id'] as String?);
  }

  @override
  HorizontalRuleNode copy() {
    return HorizontalRuleNode(id: id);
  }
}

/// A code block node
class CodeBlockNode extends DocumentNode {
  /// The code content
  String code;

  /// The programming language
  String? language;

  /// Creates a new code block node
  CodeBlockNode({
    super.id,
    required this.code,
    this.language,
  });

  @override
  bool get isEmpty => code.isEmpty;

  @override
  String get plainText => code;

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'codeBlock',
      'id': id,
      'code': code,
      if (language != null) 'language': language,
    };
  }

  factory CodeBlockNode.fromJson(Map<String, dynamic> json) {
    return CodeBlockNode(
      id: json['id'] as String?,
      code: json['code'] as String,
      language: json['language'] as String?,
    );
  }

  @override
  CodeBlockNode copy() {
    return CodeBlockNode(
      id: id,
      code: code,
      language: language,
    );
  }
}
