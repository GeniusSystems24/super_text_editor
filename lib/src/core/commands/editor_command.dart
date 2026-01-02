import '../document/document.dart';
import '../document/nodes.dart';
import '../document/attributed_text.dart';
import '../selection/editor_selection.dart';

/// Base class for all editor commands
abstract class EditorCommand {
  /// A description of this command for debugging
  String get description;

  /// Executes the command
  void execute(EditorContext context);

  /// Undoes the command
  void undo(EditorContext context);

  /// Whether this command can be merged with the previous command
  bool canMergeWith(EditorCommand other) => false;

  /// Merges this command with another command
  EditorCommand mergeWith(EditorCommand other) => this;
}

/// The context for editor operations
class EditorContext {
  /// The document being edited
  final Document document;

  /// The selection manager
  final SelectionManager selectionManager;

  EditorContext({
    required this.document,
    required this.selectionManager,
  });

  /// Gets the current selection
  EditorSelection? get selection => selectionManager.selection;

  /// Sets the selection
  set selection(EditorSelection? value) => selectionManager.setSelection(value);
}

/// Command to insert text at the current selection
class InsertTextCommand extends EditorCommand {
  final String text;
  final TextAttributes? attributes;

  // For undo
  EditorSelection? _previousSelection;
  String? _deletedText;

  InsertTextCommand(this.text, {this.attributes});

  @override
  String get description => 'Insert text: "$text"';

  @override
  void execute(EditorContext context) {
    final selection = context.selection;
    if (selection == null) return;

    _previousSelection = selection;

    final node = context.document.getNodeById(selection.base.nodeId);
    if (node == null) return;

    if (node is ParagraphNode) {
      // Delete selected text first if selection is not collapsed
      if (!selection.isCollapsed && selection.base.nodeId == selection.extent.nodeId) {
        final start = selection.start.offset;
        final end = selection.end.offset;
        _deletedText = node.text.text.substring(start, end);
        node.text = node.text.deleteText(start, end);
      }

      // Insert new text
      final offset = selection.start.offset;
      node.text = node.text.insertText(offset, text, attributes);

      // Update selection
      context.selection = EditorSelection.collapsed(
        selection.base.copyWith(offset: offset + text.length),
      );
    } else if (node is ListItemNode) {
      if (!selection.isCollapsed && selection.base.nodeId == selection.extent.nodeId) {
        final start = selection.start.offset;
        final end = selection.end.offset;
        _deletedText = node.text.text.substring(start, end);
        node.text = node.text.deleteText(start, end);
      }

      final offset = selection.start.offset;
      node.text = node.text.insertText(offset, text, attributes);

      context.selection = EditorSelection.collapsed(
        selection.base.copyWith(offset: offset + text.length),
      );
    } else if (node is TableNode && selection.base.isInTable) {
      final cell = node.getCell(selection.base.tableRow!, selection.base.tableCol!);

      if (!selection.isCollapsed) {
        final start = selection.start.offset;
        final end = selection.end.offset;
        _deletedText = cell.text.text.substring(start, end);
        cell.text = cell.text.deleteText(start, end);
      }

      final offset = selection.start.offset;
      cell.text = cell.text.insertText(offset, text, attributes);

      context.selection = EditorSelection.collapsed(
        selection.base.copyWith(offset: offset + text.length),
      );
    }
  }

  @override
  void undo(EditorContext context) {
    if (_previousSelection == null) return;

    final node = context.document.getNodeById(_previousSelection!.base.nodeId);
    if (node == null) return;

    if (node is ParagraphNode) {
      final offset = _previousSelection!.start.offset;
      node.text = node.text.deleteText(offset, offset + text.length);
      if (_deletedText != null) {
        node.text = node.text.insertText(offset, _deletedText!);
      }
    } else if (node is ListItemNode) {
      final offset = _previousSelection!.start.offset;
      node.text = node.text.deleteText(offset, offset + text.length);
      if (_deletedText != null) {
        node.text = node.text.insertText(offset, _deletedText!);
      }
    }

    context.selection = _previousSelection;
  }

  @override
  bool canMergeWith(EditorCommand other) {
    return other is InsertTextCommand &&
        text.length == 1 &&
        other.text.length == 1 &&
        !text.contains('\n') &&
        !other.text.contains('\n');
  }

  @override
  EditorCommand mergeWith(EditorCommand other) {
    if (other is InsertTextCommand) {
      return InsertTextCommand(text + other.text, attributes: attributes);
    }
    return this;
  }
}

/// Command to delete text
class DeleteTextCommand extends EditorCommand {
  final bool forward; // Delete key (forward) or Backspace (backward)

  // For undo
  EditorSelection? _previousSelection;
  String? _deletedText;
  int? _deletedOffset;

  DeleteTextCommand({this.forward = false});

  @override
  String get description => forward ? 'Delete forward' : 'Delete backward';

  @override
  void execute(EditorContext context) {
    final selection = context.selection;
    if (selection == null) return;

    _previousSelection = selection;

    final node = context.document.getNodeById(selection.base.nodeId);
    if (node == null) return;

    if (node is ParagraphNode) {
      if (!selection.isCollapsed) {
        // Delete selected text
        final start = selection.start.offset;
        final end = selection.end.offset;
        _deletedText = node.text.text.substring(start, end);
        _deletedOffset = start;
        node.text = node.text.deleteText(start, end);
        context.selection = EditorSelection.collapsed(
          selection.base.copyWith(offset: start),
        );
      } else if (forward) {
        // Delete key
        if (selection.base.offset < node.text.length) {
          _deletedOffset = selection.base.offset;
          _deletedText = node.text.text.substring(selection.base.offset, selection.base.offset + 1);
          node.text = node.text.deleteText(selection.base.offset, selection.base.offset + 1);
        }
      } else {
        // Backspace
        if (selection.base.offset > 0) {
          _deletedOffset = selection.base.offset - 1;
          _deletedText = node.text.text.substring(selection.base.offset - 1, selection.base.offset);
          node.text = node.text.deleteText(selection.base.offset - 1, selection.base.offset);
          context.selection = EditorSelection.collapsed(
            selection.base.copyWith(offset: selection.base.offset - 1),
          );
        }
      }
    } else if (node is ListItemNode) {
      if (!selection.isCollapsed) {
        final start = selection.start.offset;
        final end = selection.end.offset;
        _deletedText = node.text.text.substring(start, end);
        _deletedOffset = start;
        node.text = node.text.deleteText(start, end);
        context.selection = EditorSelection.collapsed(
          selection.base.copyWith(offset: start),
        );
      } else if (forward) {
        if (selection.base.offset < node.text.length) {
          _deletedOffset = selection.base.offset;
          _deletedText = node.text.text.substring(selection.base.offset, selection.base.offset + 1);
          node.text = node.text.deleteText(selection.base.offset, selection.base.offset + 1);
        }
      } else {
        if (selection.base.offset > 0) {
          _deletedOffset = selection.base.offset - 1;
          _deletedText = node.text.text.substring(selection.base.offset - 1, selection.base.offset);
          node.text = node.text.deleteText(selection.base.offset - 1, selection.base.offset);
          context.selection = EditorSelection.collapsed(
            selection.base.copyWith(offset: selection.base.offset - 1),
          );
        }
      }
    }
  }

  @override
  void undo(EditorContext context) {
    if (_previousSelection == null || _deletedText == null || _deletedOffset == null) return;

    final node = context.document.getNodeById(_previousSelection!.base.nodeId);
    if (node == null) return;

    if (node is ParagraphNode) {
      node.text = node.text.insertText(_deletedOffset!, _deletedText!);
    } else if (node is ListItemNode) {
      node.text = node.text.insertText(_deletedOffset!, _deletedText!);
    }

    context.selection = _previousSelection;
  }
}

/// Command to toggle text formatting
class ToggleFormatCommand extends EditorCommand {
  final String format; // 'bold', 'italic', 'underline', etc.

  // For undo
  EditorSelection? _previousSelection;

  ToggleFormatCommand(this.format);

  @override
  String get description => 'Toggle $format';

  @override
  void execute(EditorContext context) {
    final selection = context.selection;
    if (selection == null || selection.isCollapsed) return;

    _previousSelection = selection;

    if (selection.base.nodeId != selection.extent.nodeId) return;

    final node = context.document.getNodeById(selection.base.nodeId);
    if (node == null) return;

    final start = selection.start.offset;
    final end = selection.end.offset;

    if (node is ParagraphNode) {
      node.text = node.text.toggleAttribute(start, end, format);
    } else if (node is ListItemNode) {
      node.text = node.text.toggleAttribute(start, end, format);
    }
  }

  @override
  void undo(EditorContext context) {
    // Toggle back
    execute(context);
    context.selection = _previousSelection;
  }
}

/// Command to set text alignment
class SetAlignmentCommand extends EditorCommand {
  final TextAlign alignment;

  // For undo
  TextAlign? _previousAlignment;
  String? _nodeId;

  SetAlignmentCommand(this.alignment);

  @override
  String get description => 'Set alignment to ${alignment.name}';

  @override
  void execute(EditorContext context) {
    final selection = context.selection;
    if (selection == null) return;

    final node = context.document.getNodeById(selection.base.nodeId);
    if (node == null) return;

    _nodeId = selection.base.nodeId;

    if (node is ParagraphNode) {
      _previousAlignment = node.alignment;
      node.alignment = alignment;
    }
  }

  @override
  void undo(EditorContext context) {
    if (_nodeId == null || _previousAlignment == null) return;

    final node = context.document.getNodeById(_nodeId!);
    if (node is ParagraphNode) {
      node.alignment = _previousAlignment!;
    }
  }
}

/// Command to insert a new paragraph
class InsertParagraphCommand extends EditorCommand {
  // For undo
  EditorSelection? _previousSelection;
  String? _insertedNodeId;

  InsertParagraphCommand();

  @override
  String get description => 'Insert paragraph';

  @override
  void execute(EditorContext context) {
    final selection = context.selection;
    if (selection == null) return;

    _previousSelection = selection;

    final nodeIndex = context.document.getNodeIndex(selection.base.nodeId);
    if (nodeIndex == -1) return;

    final currentNode = context.document.getNodeAt(nodeIndex);

    if (currentNode is ParagraphNode) {
      // Split paragraph at cursor
      final offset = selection.base.offset;
      final textBefore = currentNode.text.substring(0, offset);
      final textAfter = currentNode.text.substring(offset);

      currentNode.text = textBefore;

      final newNode = ParagraphNode(text: textAfter);
      _insertedNodeId = newNode.id;
      context.document.insertNode(nodeIndex + 1, newNode);

      context.selection = EditorSelection.collapsed(
        NodePosition(nodeId: newNode.id, offset: 0),
      );
    } else if (currentNode is ListItemNode) {
      // Create new list item
      final offset = selection.base.offset;
      final textBefore = currentNode.text.substring(0, offset);
      final textAfter = currentNode.text.substring(offset);

      currentNode.text = textBefore;

      final newNode = ListItemNode(
        text: textAfter,
        listType: currentNode.listType,
        indentLevel: currentNode.indentLevel,
      );
      _insertedNodeId = newNode.id;
      context.document.insertNode(nodeIndex + 1, newNode);

      context.selection = EditorSelection.collapsed(
        NodePosition(nodeId: newNode.id, offset: 0),
      );
    } else {
      // Just insert a new paragraph after
      final newNode = ParagraphNode();
      _insertedNodeId = newNode.id;
      context.document.insertNode(nodeIndex + 1, newNode);

      context.selection = EditorSelection.collapsed(
        NodePosition(nodeId: newNode.id, offset: 0),
      );
    }
  }

  @override
  void undo(EditorContext context) {
    if (_previousSelection == null || _insertedNodeId == null) return;

    // Remove inserted node
    context.document.removeNode(_insertedNodeId!);

    // Restore previous selection
    context.selection = _previousSelection;
  }
}

/// Command to insert a table
class InsertTableCommand extends EditorCommand {
  final int rows;
  final int columns;

  // For undo
  EditorSelection? _previousSelection;
  String? _insertedNodeId;

  InsertTableCommand({required this.rows, required this.columns});

  @override
  String get description => 'Insert ${rows}x$columns table';

  @override
  void execute(EditorContext context) {
    final selection = context.selection;
    if (selection == null) return;

    _previousSelection = selection;

    final nodeIndex = context.document.getNodeIndex(selection.base.nodeId);
    if (nodeIndex == -1) return;

    final tableNode = TableNode.withSize(rows, columns);
    _insertedNodeId = tableNode.id;

    context.document.insertNode(nodeIndex + 1, tableNode);

    // Select first cell
    context.selection = EditorSelection.collapsed(
      NodePosition(nodeId: tableNode.id, offset: 0, tableRow: 0, tableCol: 0),
    );
  }

  @override
  void undo(EditorContext context) {
    if (_insertedNodeId == null) return;
    context.document.removeNode(_insertedNodeId!);
    context.selection = _previousSelection;
  }
}

/// Command to add a table row
class AddTableRowCommand extends EditorCommand {
  final bool above; // Add above or below current row

  // For undo
  EditorSelection? _previousSelection;
  int? _insertedRowIndex;
  String? _tableNodeId;

  AddTableRowCommand({this.above = false});

  @override
  String get description => 'Add row ${above ? 'above' : 'below'}';

  @override
  void execute(EditorContext context) {
    final selection = context.selection;
    if (selection == null || !selection.base.isInTable) return;

    _previousSelection = selection;
    _tableNodeId = selection.base.nodeId;

    final node = context.document.getNodeById(selection.base.nodeId);
    if (node is! TableNode) return;

    final currentRow = selection.base.tableRow!;
    _insertedRowIndex = above ? currentRow : currentRow + 1;
    node.insertRow(_insertedRowIndex!);

    // Update selection to new row
    context.selection = EditorSelection.collapsed(
      selection.base.copyWith(tableRow: _insertedRowIndex, offset: 0),
    );
  }

  @override
  void undo(EditorContext context) {
    if (_tableNodeId == null || _insertedRowIndex == null) return;

    final node = context.document.getNodeById(_tableNodeId!);
    if (node is! TableNode) return;

    node.removeRow(_insertedRowIndex!);
    context.selection = _previousSelection;
  }
}

/// Command to add a table column
class AddTableColumnCommand extends EditorCommand {
  final bool left; // Add to left or right of current column

  // For undo
  EditorSelection? _previousSelection;
  int? _insertedColIndex;
  String? _tableNodeId;

  AddTableColumnCommand({this.left = false});

  @override
  String get description => 'Add column ${left ? 'left' : 'right'}';

  @override
  void execute(EditorContext context) {
    final selection = context.selection;
    if (selection == null || !selection.base.isInTable) return;

    _previousSelection = selection;
    _tableNodeId = selection.base.nodeId;

    final node = context.document.getNodeById(selection.base.nodeId);
    if (node is! TableNode) return;

    final currentCol = selection.base.tableCol!;
    _insertedColIndex = left ? currentCol : currentCol + 1;
    node.insertColumn(_insertedColIndex!);

    // Update selection to new column
    context.selection = EditorSelection.collapsed(
      selection.base.copyWith(tableCol: _insertedColIndex, offset: 0),
    );
  }

  @override
  void undo(EditorContext context) {
    if (_tableNodeId == null || _insertedColIndex == null) return;

    final node = context.document.getNodeById(_tableNodeId!);
    if (node is! TableNode) return;

    node.removeColumn(_insertedColIndex!);
    context.selection = _previousSelection;
  }
}

/// Command to delete a table row
class DeleteTableRowCommand extends EditorCommand {
  // For undo
  EditorSelection? _previousSelection;
  int? _deletedRowIndex;
  String? _tableNodeId;
  List<TableCell>? _deletedCells;

  DeleteTableRowCommand();

  @override
  String get description => 'Delete row';

  @override
  void execute(EditorContext context) {
    final selection = context.selection;
    if (selection == null || !selection.base.isInTable) return;

    _previousSelection = selection;
    _tableNodeId = selection.base.nodeId;

    final node = context.document.getNodeById(selection.base.nodeId);
    if (node is! TableNode) return;

    if (node.rowCount <= 1) return; // Don't delete last row

    _deletedRowIndex = selection.base.tableRow!;
    _deletedCells = node.removeRow(_deletedRowIndex!);

    // Update selection
    final newRow = _deletedRowIndex! >= node.rowCount ? node.rowCount - 1 : _deletedRowIndex!;
    context.selection = EditorSelection.collapsed(
      selection.base.copyWith(tableRow: newRow, offset: 0),
    );
  }

  @override
  void undo(EditorContext context) {
    if (_tableNodeId == null || _deletedRowIndex == null || _deletedCells == null) return;

    final node = context.document.getNodeById(_tableNodeId!);
    if (node is! TableNode) return;

    node.insertRow(_deletedRowIndex!, _deletedCells);
    context.selection = _previousSelection;
  }
}

/// Command to delete a table column
class DeleteTableColumnCommand extends EditorCommand {
  // For undo
  EditorSelection? _previousSelection;
  int? _deletedColIndex;
  String? _tableNodeId;
  List<TableCell>? _deletedCells;

  DeleteTableColumnCommand();

  @override
  String get description => 'Delete column';

  @override
  void execute(EditorContext context) {
    final selection = context.selection;
    if (selection == null || !selection.base.isInTable) return;

    _previousSelection = selection;
    _tableNodeId = selection.base.nodeId;

    final node = context.document.getNodeById(selection.base.nodeId);
    if (node is! TableNode) return;

    if (node.columnCount <= 1) return; // Don't delete last column

    _deletedColIndex = selection.base.tableCol!;
    _deletedCells = node.removeColumn(_deletedColIndex!);

    // Update selection
    final newCol = _deletedColIndex! >= node.columnCount ? node.columnCount - 1 : _deletedColIndex!;
    context.selection = EditorSelection.collapsed(
      selection.base.copyWith(tableCol: newCol, offset: 0),
    );
  }

  @override
  void undo(EditorContext context) {
    if (_tableNodeId == null || _deletedColIndex == null || _deletedCells == null) return;

    final node = context.document.getNodeById(_tableNodeId!);
    if (node is! TableNode) return;

    node.insertColumn(_deletedColIndex!, _deletedCells);
    context.selection = _previousSelection;
  }
}

/// Command to toggle list type
class ToggleListCommand extends EditorCommand {
  final ListType listType;

  // For undo
  EditorSelection? _previousSelection;
  String? _nodeId;
  DocumentNode? _previousNode;

  ToggleListCommand(this.listType);

  @override
  String get description => 'Toggle ${listType.name} list';

  @override
  void execute(EditorContext context) {
    final selection = context.selection;
    if (selection == null) return;

    _previousSelection = selection;
    _nodeId = selection.base.nodeId;

    final nodeIndex = context.document.getNodeIndex(selection.base.nodeId);
    if (nodeIndex == -1) return;

    final node = context.document.getNodeAt(nodeIndex);
    _previousNode = node.copy();

    if (node is ParagraphNode) {
      // Convert to list item
      final listItem = ListItemNode(
        text: node.text,
        listType: listType,
      );
      context.document.replaceNode(nodeIndex, listItem);
      context.selection = EditorSelection.collapsed(
        NodePosition(nodeId: listItem.id, offset: selection.base.offset),
      );
    } else if (node is ListItemNode) {
      if (node.listType == listType) {
        // Convert back to paragraph
        final paragraph = ParagraphNode(text: node.text);
        context.document.replaceNode(nodeIndex, paragraph);
        context.selection = EditorSelection.collapsed(
          NodePosition(nodeId: paragraph.id, offset: selection.base.offset),
        );
      } else {
        // Change list type
        node.listType = listType;
      }
    }
  }

  @override
  void undo(EditorContext context) {
    if (_nodeId == null || _previousNode == null) return;

    final nodeIndex = context.document.getNodeIndex(context.selection?.base.nodeId ?? '');
    if (nodeIndex != -1) {
      context.document.replaceNode(nodeIndex, _previousNode!);
    }
    context.selection = _previousSelection;
  }
}

/// Command to set block type (heading, etc.)
class SetBlockTypeCommand extends EditorCommand {
  final BlockType blockType;

  // For undo
  EditorSelection? _previousSelection;
  BlockType? _previousBlockType;

  SetBlockTypeCommand(this.blockType);

  @override
  String get description => 'Set block type to ${blockType.name}';

  @override
  void execute(EditorContext context) {
    final selection = context.selection;
    if (selection == null) return;

    _previousSelection = selection;

    final node = context.document.getNodeById(selection.base.nodeId);
    if (node is! ParagraphNode) return;

    _previousBlockType = node.blockType;
    node.blockType = blockType;
  }

  @override
  void undo(EditorContext context) {
    if (_previousSelection == null || _previousBlockType == null) return;

    final node = context.document.getNodeById(_previousSelection!.base.nodeId);
    if (node is! ParagraphNode) return;

    node.blockType = _previousBlockType!;
    context.selection = _previousSelection;
  }
}

/// Command to insert a link
class InsertLinkCommand extends EditorCommand {
  final String url;
  final String text;

  // For undo
  EditorSelection? _previousSelection;

  InsertLinkCommand({required this.url, required this.text});

  @override
  String get description => 'Insert link: $url';

  @override
  void execute(EditorContext context) {
    final selection = context.selection;
    if (selection == null) return;

    _previousSelection = selection;

    final node = context.document.getNodeById(selection.base.nodeId);
    if (node == null) return;

    final linkAttributes = TextAttributes(linkUrl: url, underline: true);

    if (node is ParagraphNode) {
      if (!selection.isCollapsed) {
        // Apply link to selected text
        final start = selection.start.offset;
        final end = selection.end.offset;
        node.text = node.text.applyAttributes(start, end, linkAttributes);
      } else {
        // Insert link text
        final offset = selection.base.offset;
        node.text = node.text.insertText(offset, text, linkAttributes);
        context.selection = EditorSelection.collapsed(
          selection.base.copyWith(offset: offset + text.length),
        );
      }
    }
  }

  @override
  void undo(EditorContext context) {
    // This is simplified - a proper implementation would restore the original state
    context.selection = _previousSelection;
  }
}

/// Command to insert an image
class InsertImageCommand extends EditorCommand {
  final String src;
  final String alt;
  final double? width;
  final double? height;

  // For undo
  EditorSelection? _previousSelection;
  String? _insertedNodeId;

  InsertImageCommand({
    required this.src,
    this.alt = '',
    this.width,
    this.height,
  });

  @override
  String get description => 'Insert image: $src';

  @override
  void execute(EditorContext context) {
    final selection = context.selection;
    if (selection == null) return;

    _previousSelection = selection;

    final nodeIndex = context.document.getNodeIndex(selection.base.nodeId);
    if (nodeIndex == -1) return;

    final imageNode = ImageNode(
      src: src,
      alt: alt,
      width: width,
      height: height,
    );
    _insertedNodeId = imageNode.id;

    context.document.insertNode(nodeIndex + 1, imageNode);

    // Move selection after image
    final newParagraph = ParagraphNode();
    context.document.insertNode(nodeIndex + 2, newParagraph);
    context.selection = EditorSelection.collapsed(
      NodePosition(nodeId: newParagraph.id, offset: 0),
    );
  }

  @override
  void undo(EditorContext context) {
    if (_insertedNodeId == null) return;
    context.document.removeNode(_insertedNodeId!);
    context.selection = _previousSelection;
  }
}
