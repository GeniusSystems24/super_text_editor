import 'package:flutter/material.dart';
import '../enums/list_type.dart';
import '../enums/paragraph_type.dart';
import '../enums/text_alignment.dart';
import 'editor_node.dart';
import 'text_style_model.dart';

/// Represents the complete state of the editor
class EditorState {
  /// All document nodes
  final List<EditorNode> nodes;

  /// Current selection
  final EditorSelection selection;

  /// Current text style at cursor position
  final TextStyleModel currentStyle;

  /// Current paragraph type
  final ParagraphType currentParagraphType;

  /// Current text alignment
  final TextAlignment currentAlignment;

  /// Current list type
  final ListType currentListType;

  /// Undo history
  final List<EditorState> undoStack;

  /// Redo history
  final List<EditorState> redoStack;

  /// Creates a new EditorState
  const EditorState({
    this.nodes = const [],
    this.selection = const EditorSelection.collapsed(),
    this.currentStyle = const TextStyleModel(),
    this.currentParagraphType = ParagraphType.paragraph,
    this.currentAlignment = TextAlignment.left,
    this.currentListType = ListType.none,
    this.undoStack = const [],
    this.redoStack = const [],
  });

  /// Creates an empty editor state with a single empty paragraph
  factory EditorState.empty() {
    return EditorState(
      nodes: [
        ParagraphNode(
          children: [TextSpanNode(text: '')],
        ),
      ],
    );
  }

  /// Returns true if undo is available
  bool get canUndo => undoStack.isNotEmpty;

  /// Returns true if redo is available
  bool get canRedo => redoStack.isNotEmpty;

  /// Returns the document as HTML
  String toHtml() {
    return nodes.map((node) => node.toHtml()).join('\n');
  }

  /// Returns the plain text content
  String toPlainText() {
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
      }
    }
    return buffer.toString().trimRight();
  }

  /// Creates a copy with modified properties
  EditorState copyWith({
    List<EditorNode>? nodes,
    EditorSelection? selection,
    TextStyleModel? currentStyle,
    ParagraphType? currentParagraphType,
    TextAlignment? currentAlignment,
    ListType? currentListType,
    List<EditorState>? undoStack,
    List<EditorState>? redoStack,
  }) {
    return EditorState(
      nodes: nodes ?? this.nodes,
      selection: selection ?? this.selection,
      currentStyle: currentStyle ?? this.currentStyle,
      currentParagraphType: currentParagraphType ?? this.currentParagraphType,
      currentAlignment: currentAlignment ?? this.currentAlignment,
      currentListType: currentListType ?? this.currentListType,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
    );
  }
}

/// Represents a selection in the editor
class EditorSelection {
  /// The start position
  final EditorPosition start;

  /// The end position
  final EditorPosition end;

  /// Creates a new EditorSelection
  const EditorSelection({
    required this.start,
    required this.end,
  });

  /// Creates a collapsed selection at the given position
  const EditorSelection.collapsed({
    EditorPosition position = const EditorPosition(),
  })  : start = position,
        end = position;

  /// Returns true if this is a collapsed selection (cursor)
  bool get isCollapsed => start == end;

  /// Returns true if text is selected
  bool get hasSelection => !isCollapsed;

  /// Creates a copy with modified properties
  EditorSelection copyWith({
    EditorPosition? start,
    EditorPosition? end,
  }) {
    return EditorSelection(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}

/// Represents a position in the editor
class EditorPosition {
  /// The node index
  final int nodeIndex;

  /// The offset within the node
  final int offset;

  /// Creates a new EditorPosition
  const EditorPosition({
    this.nodeIndex = 0,
    this.offset = 0,
  });

  /// Creates a copy with modified properties
  EditorPosition copyWith({
    int? nodeIndex,
    int? offset,
  }) {
    return EditorPosition(
      nodeIndex: nodeIndex ?? this.nodeIndex,
      offset: offset ?? this.offset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EditorPosition &&
        other.nodeIndex == nodeIndex &&
        other.offset == offset;
  }

  @override
  int get hashCode => Object.hash(nodeIndex, offset);
}
