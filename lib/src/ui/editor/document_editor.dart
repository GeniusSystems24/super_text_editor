import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/document/document.dart';
import '../../core/document/nodes.dart';
import '../../core/selection/editor_selection.dart';
import '../../core/commands/editor_command.dart';
import '../../core/history/undo_redo.dart';
import '../components/paragraph_component.dart';
import '../components/list_item_component.dart';
import '../components/table_component.dart';
import '../components/image_component.dart';
import '../components/horizontal_rule_component.dart';
import '../components/code_block_component.dart';

/// Controller for the document editor
class DocumentEditorController extends ChangeNotifier {
  /// The document being edited
  final Document document;

  /// The selection manager
  final SelectionManager selectionManager;

  /// The command history
  final EditorHistory history;

  /// The editor context
  late final EditorContext context;

  /// Creates a new document editor controller
  DocumentEditorController({
    Document? document,
  })  : document = document ?? Document.empty(),
        selectionManager = SelectionManager(document ?? Document.empty()),
        history = EditorHistory() {
    context = EditorContext(
      document: this.document,
      selectionManager: selectionManager,
    );

    this.document.addListener(_onDocumentChanged);
    selectionManager.addListener(_onSelectionChanged);
  }

  void _onDocumentChanged() {
    notifyListeners();
  }

  void _onSelectionChanged(EditorSelection? selection) {
    notifyListeners();
  }

  /// Gets the current selection
  EditorSelection? get selection => selectionManager.selection;

  /// Gets the current node (where cursor is)
  DocumentNode? get currentNode {
    final sel = selection;
    if (sel == null) return null;
    return document.getNodeById(sel.base.nodeId);
  }

  /// Executes a command
  void execute(EditorCommand command) {
    history.execute(command, context);
    notifyListeners();
  }

  /// Undoes the last command
  void undo() {
    history.undo(context);
    notifyListeners();
  }

  /// Redoes the last undone command
  void redo() {
    history.redo(context);
    notifyListeners();
  }

  /// Whether undo is available
  bool get canUndo => history.canUndo;

  /// Whether redo is available
  bool get canRedo => history.canRedo;

  /// Inserts text at the current selection
  void insertText(String text) {
    execute(InsertTextCommand(text));
  }

  /// Deletes text (backspace)
  void deleteBackward() {
    execute(DeleteTextCommand(forward: false));
  }

  /// Deletes text (delete key)
  void deleteForward() {
    execute(DeleteTextCommand(forward: true));
  }

  /// Inserts a new paragraph (Enter key)
  void insertParagraph() {
    execute(InsertParagraphCommand());
  }

  /// Toggles bold formatting
  void toggleBold() {
    execute(ToggleFormatCommand('bold'));
  }

  /// Toggles italic formatting
  void toggleItalic() {
    execute(ToggleFormatCommand('italic'));
  }

  /// Toggles underline formatting
  void toggleUnderline() {
    execute(ToggleFormatCommand('underline'));
  }

  /// Toggles strikethrough formatting
  void toggleStrikethrough() {
    execute(ToggleFormatCommand('strikethrough'));
  }

  /// Sets text alignment
  void setAlignment(TextAlign alignment) {
    execute(SetAlignmentCommand(alignment));
  }

  /// Toggles bullet list
  void toggleBulletList() {
    execute(ToggleListCommand(ListType.bullet));
  }

  /// Toggles numbered list
  void toggleNumberedList() {
    execute(ToggleListCommand(ListType.numbered));
  }

  /// Sets block type (heading, etc.)
  void setBlockType(BlockType blockType) {
    execute(SetBlockTypeCommand(blockType));
  }

  /// Inserts a table
  void insertTable(int rows, int columns) {
    execute(InsertTableCommand(rows: rows, columns: columns));
  }

  /// Adds a table row
  void addTableRow({bool above = false}) {
    execute(AddTableRowCommand(above: above));
  }

  /// Adds a table column
  void addTableColumn({bool left = false}) {
    execute(AddTableColumnCommand(left: left));
  }

  /// Deletes a table row
  void deleteTableRow() {
    execute(DeleteTableRowCommand());
  }

  /// Deletes a table column
  void deleteTableColumn() {
    execute(DeleteTableColumnCommand());
  }

  /// Inserts a link
  void insertLink(String url, String text) {
    execute(InsertLinkCommand(url: url, text: text));
  }

  /// Inserts an image
  void insertImage(String src, {String alt = '', double? width, double? height}) {
    execute(InsertImageCommand(src: src, alt: alt, width: width, height: height));
  }

  /// Gets the HTML representation of the document
  String get html {
    // This would use the HTML exporter
    return '';
  }

  /// Gets the JSON representation of the document
  Map<String, dynamic> get json => document.toJson();

  /// Loads a document from JSON
  void loadFromJson(Map<String, dynamic> json) {
    final newDoc = Document.fromJson(json);
    document.clear();
    for (final node in newDoc.nodes) {
      document.insertNode(document.length, node);
    }
    // Remove the initial empty paragraph if document has content
    if (document.length > 1 && document.getNodeAt(0).isEmpty) {
      document.removeNodeAt(0);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    document.removeListener(_onDocumentChanged);
    selectionManager.dispose();
    super.dispose();
  }
}

/// The main document editor widget
class DocumentEditor extends StatefulWidget {
  /// The editor controller
  final DocumentEditorController? controller;

  /// Placeholder text when document is empty
  final String placeholder;

  /// Whether the editor is read-only
  final bool readOnly;

  /// Whether to auto-focus the editor
  final bool autofocus;

  /// Minimum height of the editor
  final double? minHeight;

  /// Maximum height of the editor
  final double? maxHeight;

  /// Padding inside the editor
  final EdgeInsets padding;

  /// Callback when content changes
  final VoidCallback? onChanged;

  /// Text direction
  final TextDirection textDirection;

  /// Creates a new document editor
  const DocumentEditor({
    super.key,
    this.controller,
    this.placeholder = 'Start typing...',
    this.readOnly = false,
    this.autofocus = false,
    this.minHeight,
    this.maxHeight,
    this.padding = const EdgeInsets.all(16),
    this.onChanged,
    this.textDirection = TextDirection.ltr,
  });

  @override
  State<DocumentEditor> createState() => _DocumentEditorState();
}

class _DocumentEditorState extends State<DocumentEditor> {
  late DocumentEditorController _controller;
  bool _isInternalController = false;
  final FocusNode _focusNode = FocusNode();
  final Map<String, FocusNode> _nodeFocusNodes = {};
  final Map<String, TextEditingController> _nodeTextControllers = {};

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isInternalController = false;
    } else {
      _controller = DocumentEditorController();
      _isInternalController = true;
    }
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    setState(() {});
    widget.onChanged?.call();
  }

  @override
  void didUpdateWidget(DocumentEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_isInternalController) {
        _controller.removeListener(_onControllerChanged);
        _controller.dispose();
      }
      _initController();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_isInternalController) {
      _controller.dispose();
    }
    _focusNode.dispose();
    for (final node in _nodeFocusNodes.values) {
      node.dispose();
    }
    for (final controller in _nodeTextControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  FocusNode _getOrCreateFocusNode(String nodeId) {
    return _nodeFocusNodes.putIfAbsent(nodeId, () => FocusNode());
  }

  TextEditingController _getOrCreateTextController(String nodeId, String initialText) {
    if (!_nodeTextControllers.containsKey(nodeId)) {
      _nodeTextControllers[nodeId] = TextEditingController(text: initialText);
    }
    return _nodeTextControllers[nodeId]!;
  }

  void _handleKeyEvent(KeyEvent event) {
    if (widget.readOnly) return;

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      final isCtrl = HardwareKeyboard.instance.isControlPressed;
      final isMeta = HardwareKeyboard.instance.isMetaPressed;
      final isModifier = isCtrl || isMeta;

      if (isModifier) {
        if (event.logicalKey == LogicalKeyboardKey.keyZ) {
          if (HardwareKeyboard.instance.isShiftPressed) {
            _controller.redo();
          } else {
            _controller.undo();
          }
        } else if (event.logicalKey == LogicalKeyboardKey.keyY) {
          _controller.redo();
        } else if (event.logicalKey == LogicalKeyboardKey.keyB) {
          _controller.toggleBold();
        } else if (event.logicalKey == LogicalKeyboardKey.keyI) {
          _controller.toggleItalic();
        } else if (event.logicalKey == LogicalKeyboardKey.keyU) {
          _controller.toggleUnderline();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Container(
        constraints: BoxConstraints(
          minHeight: widget.minHeight ?? 100,
          maxHeight: widget.maxHeight ?? double.infinity,
        ),
        child: SingleChildScrollView(
          padding: widget.padding,
          child: Directionality(
            textDirection: widget.textDirection,
            child: _buildDocument(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildDocument(ThemeData theme) {
    if (_controller.document.isEmpty && widget.placeholder.isNotEmpty) {
      return _buildPlaceholder(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < _controller.document.length; i++)
          _buildNode(_controller.document.getNodeAt(i), i, theme),
      ],
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        if (!widget.readOnly) {
          final firstNode = _controller.document.getNodeAt(0);
          _controller.selectionManager.collapse(
            NodePosition(nodeId: firstNode.id, offset: 0),
          );
          _getOrCreateFocusNode(firstNode.id).requestFocus();
        }
      },
      child: Text(
        widget.placeholder,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.hintColor,
        ),
      ),
    );
  }

  Widget _buildNode(DocumentNode node, int index, ThemeData theme) {
    if (node is ParagraphNode) {
      return ParagraphComponent(
        key: ValueKey(node.id),
        node: node,
        focusNode: _getOrCreateFocusNode(node.id),
        textController: _getOrCreateTextController(node.id, node.plainText),
        readOnly: widget.readOnly,
        onTextChanged: (text) => _handleTextChanged(node, text),
        onSelectionChanged: (selection) => _handleSelectionChanged(node, selection),
        onSubmitted: () => _controller.insertParagraph(),
        onBackspace: () => _handleBackspace(node, index),
      );
    } else if (node is ListItemNode) {
      return ListItemComponent(
        key: ValueKey(node.id),
        node: node,
        focusNode: _getOrCreateFocusNode(node.id),
        textController: _getOrCreateTextController(node.id, node.plainText),
        readOnly: widget.readOnly,
        onTextChanged: (text) => _handleTextChanged(node, text),
        onSelectionChanged: (selection) => _handleSelectionChanged(node, selection),
        onSubmitted: () => _controller.insertParagraph(),
        onBackspace: () => _handleBackspace(node, index),
      );
    } else if (node is TableNode) {
      return TableComponent(
        key: ValueKey(node.id),
        node: node,
        readOnly: widget.readOnly,
        onCellChanged: (row, col, text) => _handleTableCellChanged(node, row, col, text),
        onCellFocused: (row, col) => _handleTableCellFocused(node, row, col),
        onAddRow: (above) => _controller.addTableRow(above: above),
        onAddColumn: (left) => _controller.addTableColumn(left: left),
        onDeleteRow: () => _controller.deleteTableRow(),
        onDeleteColumn: () => _controller.deleteTableColumn(),
      );
    } else if (node is ImageNode) {
      return ImageComponent(
        key: ValueKey(node.id),
        node: node,
        onTap: () => _handleNodeTap(node),
      );
    } else if (node is HorizontalRuleNode) {
      return HorizontalRuleComponent(
        key: ValueKey(node.id),
        node: node,
        onTap: () => _handleNodeTap(node),
      );
    } else if (node is CodeBlockNode) {
      return CodeBlockComponent(
        key: ValueKey(node.id),
        node: node,
        focusNode: _getOrCreateFocusNode(node.id),
        textController: _getOrCreateTextController(node.id, node.code),
        readOnly: widget.readOnly,
        onCodeChanged: (code) {
          node.code = code;
          _controller.notifyListeners();
        },
      );
    }

    // Fallback for unknown node types
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text('Unknown node type: ${node.runtimeType}'),
    );
  }

  void _handleTextChanged(DocumentNode node, String text) {
    if (node is ParagraphNode) {
      // Update the attributed text while preserving spans
      final oldText = node.text.text;
      if (text != oldText) {
        // Simple replacement - more sophisticated handling would preserve spans
        node.text = node.text.copyWith(text: text, spans: []);
        _controller.notifyListeners();
      }
    } else if (node is ListItemNode) {
      final oldText = node.text.text;
      if (text != oldText) {
        node.text = node.text.copyWith(text: text, spans: []);
        _controller.notifyListeners();
      }
    }
  }

  void _handleSelectionChanged(DocumentNode node, TextSelection selection) {
    _controller.selectionManager.setSelection(
      EditorSelection(
        base: NodePosition(nodeId: node.id, offset: selection.baseOffset),
        extent: NodePosition(nodeId: node.id, offset: selection.extentOffset),
      ),
    );
  }

  void _handleBackspace(DocumentNode node, int index) {
    final textController = _nodeTextControllers[node.id];
    if (textController != null && textController.selection.baseOffset == 0) {
      // At the beginning of the node - merge with previous node
      if (index > 0) {
        // TODO: Implement node merging
      }
    }
  }

  void _handleTableCellChanged(TableNode node, int row, int col, String text) {
    final cell = node.getCell(row, col);
    cell.text = cell.text.copyWith(text: text, spans: []);
    _controller.notifyListeners();
  }

  void _handleTableCellFocused(TableNode node, int row, int col) {
    _controller.selectionManager.setSelection(
      EditorSelection.collapsed(
        NodePosition(nodeId: node.id, offset: 0, tableRow: row, tableCol: col),
      ),
    );
  }

  void _handleNodeTap(DocumentNode node) {
    _controller.selectionManager.collapse(
      NodePosition(nodeId: node.id, offset: 0),
    );
  }
}
