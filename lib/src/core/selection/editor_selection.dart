import '../document/document.dart';

/// Represents a position within a document node
class NodePosition {
  /// The node ID
  final String nodeId;

  /// The offset within the node (for text nodes)
  final int offset;

  /// For table nodes: the row index
  final int? tableRow;

  /// For table nodes: the column index
  final int? tableCol;

  const NodePosition({
    required this.nodeId,
    this.offset = 0,
    this.tableRow,
    this.tableCol,
  });

  /// Whether this position is in a table cell
  bool get isInTable => tableRow != null && tableCol != null;

  /// Creates a copy with optional new values
  NodePosition copyWith({
    String? nodeId,
    int? offset,
    int? tableRow,
    int? tableCol,
  }) {
    return NodePosition(
      nodeId: nodeId ?? this.nodeId,
      offset: offset ?? this.offset,
      tableRow: tableRow ?? this.tableRow,
      tableCol: tableCol ?? this.tableCol,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NodePosition &&
        other.nodeId == nodeId &&
        other.offset == offset &&
        other.tableRow == tableRow &&
        other.tableCol == tableCol;
  }

  @override
  int get hashCode => Object.hash(nodeId, offset, tableRow, tableCol);

  @override
  String toString() {
    if (isInTable) {
      return 'NodePosition(nodeId: $nodeId, row: $tableRow, col: $tableCol, offset: $offset)';
    }
    return 'NodePosition(nodeId: $nodeId, offset: $offset)';
  }

  Map<String, dynamic> toJson() {
    return {
      'nodeId': nodeId,
      'offset': offset,
      if (tableRow != null) 'tableRow': tableRow,
      if (tableCol != null) 'tableCol': tableCol,
    };
  }

  factory NodePosition.fromJson(Map<String, dynamic> json) {
    return NodePosition(
      nodeId: json['nodeId'] as String,
      offset: json['offset'] as int? ?? 0,
      tableRow: json['tableRow'] as int?,
      tableCol: json['tableCol'] as int?,
    );
  }
}

/// Represents a selection within the document
class EditorSelection {
  /// The base (anchor) position of the selection
  final NodePosition base;

  /// The extent (focus) position of the selection
  final NodePosition extent;

  const EditorSelection({
    required this.base,
    required this.extent,
  });

  /// Creates a collapsed selection at the given position
  factory EditorSelection.collapsed(NodePosition position) {
    return EditorSelection(base: position, extent: position);
  }

  /// Creates a selection from base to extent
  factory EditorSelection.fromPositions(NodePosition base, NodePosition extent) {
    return EditorSelection(base: base, extent: extent);
  }

  /// Whether this selection is collapsed (cursor)
  bool get isCollapsed => base == extent;

  /// Whether this selection spans multiple nodes
  bool get spansMultipleNodes => base.nodeId != extent.nodeId;

  /// Whether this selection is within a table
  bool get isInTable => base.isInTable && extent.isInTable;

  /// The start position (earlier in document order)
  NodePosition get start => _comparePositions(base, extent) <= 0 ? base : extent;

  /// The end position (later in document order)
  NodePosition get end => _comparePositions(base, extent) <= 0 ? extent : base;

  /// Compares two positions (-1 if a before b, 0 if equal, 1 if a after b)
  int _comparePositions(NodePosition a, NodePosition b) {
    if (a.nodeId == b.nodeId) {
      if (a.isInTable && b.isInTable) {
        if (a.tableRow != b.tableRow) {
          return a.tableRow!.compareTo(b.tableRow!);
        }
        if (a.tableCol != b.tableCol) {
          return a.tableCol!.compareTo(b.tableCol!);
        }
      }
      return a.offset.compareTo(b.offset);
    }
    // Need document context to compare across nodes
    // For now, assume a comes before b if their IDs differ
    return a.nodeId.compareTo(b.nodeId);
  }

  /// Creates a copy with optional new values
  EditorSelection copyWith({
    NodePosition? base,
    NodePosition? extent,
  }) {
    return EditorSelection(
      base: base ?? this.base,
      extent: extent ?? this.extent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EditorSelection && other.base == base && other.extent == extent;
  }

  @override
  int get hashCode => Object.hash(base, extent);

  @override
  String toString() => 'EditorSelection(base: $base, extent: $extent)';

  Map<String, dynamic> toJson() {
    return {
      'base': base.toJson(),
      'extent': extent.toJson(),
    };
  }

  factory EditorSelection.fromJson(Map<String, dynamic> json) {
    return EditorSelection(
      base: NodePosition.fromJson(json['base'] as Map<String, dynamic>),
      extent: NodePosition.fromJson(json['extent'] as Map<String, dynamic>),
    );
  }
}

/// Manages selection state for the editor
class SelectionManager {
  /// The current selection
  EditorSelection? _selection;

  /// The document
  final Document document;

  /// Listeners for selection changes
  final List<void Function(EditorSelection?)> _listeners = [];

  SelectionManager(this.document);

  /// Gets the current selection
  EditorSelection? get selection => _selection;

  /// Whether there is an active selection
  bool get hasSelection => _selection != null;

  /// Whether the selection is collapsed
  bool get isCollapsed => _selection?.isCollapsed ?? true;

  /// Sets the selection
  void setSelection(EditorSelection? selection) {
    if (_selection == selection) return;
    _selection = selection;
    _notifyListeners();
  }

  /// Collapses the selection to the given position
  void collapse(NodePosition position) {
    setSelection(EditorSelection.collapsed(position));
  }

  /// Extends the selection to the given position
  void extendTo(NodePosition position) {
    if (_selection == null) {
      collapse(position);
    } else {
      setSelection(_selection!.copyWith(extent: position));
    }
  }

  /// Clears the selection
  void clear() {
    setSelection(null);
  }

  /// Moves the selection by the given offset within the current node
  void moveByOffset(int delta) {
    if (_selection == null) return;
    final newOffset = (_selection!.extent.offset + delta).clamp(0, _getNodeLength(_selection!.extent.nodeId));
    collapse(_selection!.extent.copyWith(offset: newOffset));
  }

  /// Gets the length of the content in a node
  int _getNodeLength(String nodeId) {
    final node = document.getNodeById(nodeId);
    if (node == null) return 0;
    return node.plainText.length;
  }

  /// Adds a listener for selection changes
  void addListener(void Function(EditorSelection?) listener) {
    _listeners.add(listener);
  }

  /// Removes a listener
  void removeListener(void Function(EditorSelection?) listener) {
    _listeners.remove(listener);
  }

  /// Notifies listeners of selection change
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_selection);
    }
  }

  /// Disposes resources
  void dispose() {
    _listeners.clear();
  }
}
