import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/enums/list_type.dart';
import '../../domain/enums/paragraph_type.dart';
import '../../domain/enums/text_alignment.dart';
import '../../domain/enums/text_format.dart';
import '../../domain/models/editor_node.dart';
import '../../domain/models/editor_state.dart';
import '../../domain/models/text_style_model.dart';

/// Controller for the SuperTextEditor
class SuperEditorController extends ChangeNotifier {
  /// Internal text editing controller
  final TextEditingController _textController;

  /// Focus node for the editor
  final FocusNode focusNode;

  /// Current editor state
  EditorState _state;

  /// Maximum undo history size
  final int maxUndoHistory;

  /// Creates a new SuperEditorController
  SuperEditorController({
    String? initialHtml,
    String? initialText,
    this.maxUndoHistory = 50,
    FocusNode? focusNode,
  })  : _textController = TextEditingController(text: initialText ?? ''),
        focusNode = focusNode ?? FocusNode(),
        _state = EditorState.empty() {
    if (initialHtml != null) {
      _loadHtml(initialHtml);
    } else if (initialText != null) {
      _loadPlainText(initialText);
    }

    _textController.addListener(_onTextChanged);
  }

  /// Returns the text editing controller (for internal use)
  TextEditingController get textController => _textController;

  /// Current editor state
  EditorState get state => _state;

  /// Returns the current content as HTML
  String get html => _state.toHtml();

  /// Returns the current content as plain text
  String get plainText => _textController.text;

  /// Returns true if the editor has content
  bool get hasContent => _textController.text.isNotEmpty;

  /// Returns true if undo is available
  bool get canUndo => _state.canUndo;

  /// Returns true if redo is available
  bool get canRedo => _state.canRedo;

  /// Current text style at cursor position
  TextStyleModel get currentStyle => _state.currentStyle;

  /// Current paragraph type
  ParagraphType get currentParagraphType => _state.currentParagraphType;

  /// Current text alignment
  TextAlignment get currentAlignment => _state.currentAlignment;

  /// Current list type
  ListType get currentListType => _state.currentListType;

  /// Returns true if the specified format is active
  bool isFormatActive(TextFormat format) {
    return _state.currentStyle.formats.contains(format);
  }

  void _loadHtml(String html) {
    // Parse HTML and convert to nodes - simplified implementation
    final plainText = _stripHtml(html);
    _textController.text = plainText;
    _updateNodesFromText();
  }

  void _loadPlainText(String text) {
    _textController.text = text;
    _updateNodesFromText();
  }

  String _stripHtml(String html) {
    // Simple HTML stripping - can be enhanced
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'</p>'), '\n')
        .replaceAll(RegExp(r'</div>'), '\n')
        .replaceAll(RegExp(r'</li>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .trim();
  }

  void _updateNodesFromText() {
    final text = _textController.text;
    final paragraphs = text.split('\n');

    final nodes = <EditorNode>[];
    for (final para in paragraphs) {
      nodes.add(ParagraphNode(
        type: _state.currentParagraphType,
        alignment: _state.currentAlignment,
        children: [
          TextSpanNode(
            text: para,
            style: _state.currentStyle,
          ),
        ],
      ));
    }

    _state = _state.copyWith(nodes: nodes.isEmpty ? [ParagraphNode()] : nodes);
  }

  void _onTextChanged() {
    _updateNodesFromText();
    notifyListeners();
  }

  /// Saves the current state for undo
  void _saveUndoState() {
    final undoStack = List<EditorState>.from(_state.undoStack);
    undoStack.add(_state.copyWith(undoStack: const [], redoStack: const []));

    // Limit undo history
    while (undoStack.length > maxUndoHistory) {
      undoStack.removeAt(0);
    }

    _state = _state.copyWith(undoStack: undoStack, redoStack: []);
  }

  /// Toggles the specified text format
  void toggleFormat(TextFormat format) {
    _saveUndoState();
    final newStyle = _state.currentStyle.toggleFormat(format);
    _state = _state.copyWith(currentStyle: newStyle);
    _applyFormatToSelection(format);
    notifyListeners();
  }

  void _applyFormatToSelection(TextFormat format) {
    final selection = _textController.selection;
    if (!selection.isValid || selection.isCollapsed) {
      return;
    }

    // The format will be applied to new text typed after this
    // For existing selected text, we would need to track format ranges
  }

  /// Sets the text color
  void setTextColor(Color? color) {
    _saveUndoState();
    _state = _state.copyWith(
      currentStyle: _state.currentStyle.withTextColor(color),
    );
    notifyListeners();
  }

  /// Sets the background/highlight color
  void setBackgroundColor(Color? color) {
    _saveUndoState();
    _state = _state.copyWith(
      currentStyle: _state.currentStyle.withBackgroundColor(color),
    );
    notifyListeners();
  }

  /// Sets the paragraph type
  void setParagraphType(ParagraphType type) {
    _saveUndoState();
    _state = _state.copyWith(currentParagraphType: type);
    _updateNodesFromText();
    notifyListeners();
  }

  /// Sets the text alignment
  void setAlignment(TextAlignment alignment) {
    _saveUndoState();
    _state = _state.copyWith(currentAlignment: alignment);
    _updateNodesFromText();
    notifyListeners();
  }

  /// Sets the list type
  void setListType(ListType type) {
    _saveUndoState();
    _state = _state.copyWith(currentListType: type);
    _updateNodesFromText();
    notifyListeners();
  }

  /// Increases indent level
  void indent() {
    _saveUndoState();
    // Implementation for indentation
    notifyListeners();
  }

  /// Decreases indent level
  void outdent() {
    _saveUndoState();
    // Implementation for outdentation
    notifyListeners();
  }

  /// Undoes the last action
  void undo() {
    if (!canUndo) return;

    final undoStack = List<EditorState>.from(_state.undoStack);
    final previousState = undoStack.removeLast();

    final redoStack = List<EditorState>.from(_state.redoStack);
    redoStack.add(_state.copyWith(undoStack: const [], redoStack: const []));

    _state = previousState.copyWith(
      undoStack: undoStack,
      redoStack: redoStack,
    );

    _textController.text = _state.toPlainText();
    notifyListeners();
  }

  /// Redoes the last undone action
  void redo() {
    if (!canRedo) return;

    final redoStack = List<EditorState>.from(_state.redoStack);
    final nextState = redoStack.removeLast();

    final undoStack = List<EditorState>.from(_state.undoStack);
    undoStack.add(_state.copyWith(undoStack: const [], redoStack: const []));

    _state = nextState.copyWith(
      undoStack: undoStack,
      redoStack: redoStack,
    );

    _textController.text = _state.toPlainText();
    notifyListeners();
  }

  /// Clears all formatting from selection
  void clearFormatting() {
    _saveUndoState();
    _state = _state.copyWith(
      currentStyle: TextStyleModel.empty(),
      currentParagraphType: ParagraphType.paragraph,
      currentAlignment: TextAlignment.left,
    );
    notifyListeners();
  }

  /// Inserts a horizontal rule
  void insertHorizontalRule() {
    _saveUndoState();
    final selection = _textController.selection;
    if (selection.isValid) {
      final text = _textController.text;
      final newText = '${text.substring(0, selection.start)}'
          '\n---\n'
          '${text.substring(selection.end)}';
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(
        offset: selection.start + 5,
      );
    }
    notifyListeners();
  }

  /// Inserts a link
  void insertLink(String url, String text) {
    _saveUndoState();
    final selection = _textController.selection;
    if (selection.isValid) {
      final currentText = _textController.text;
      final linkText = text.isEmpty ? url : text;
      final newText = '${currentText.substring(0, selection.start)}'
          '$linkText'
          '${currentText.substring(selection.end)}';
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(
        offset: selection.start + linkText.length,
      );
    }
    notifyListeners();
  }

  /// Inserts an image placeholder
  void insertImage(String url, {String alt = ''}) {
    _saveUndoState();
    final selection = _textController.selection;
    if (selection.isValid) {
      final text = _textController.text;
      final imageText = '[Image: $url]';
      final newText = '${text.substring(0, selection.start)}'
          '\n$imageText\n'
          '${text.substring(selection.end)}';
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(
        offset: selection.start + imageText.length + 2,
      );
    }
    notifyListeners();
  }

  /// Inserts a table
  void insertTable(int rows, int cols) {
    _saveUndoState();
    final selection = _textController.selection;
    if (selection.isValid) {
      final text = _textController.text;
      final tableText = '\n[Table: ${rows}x$cols]\n';
      final newText = '${text.substring(0, selection.start)}'
          '$tableText'
          '${text.substring(selection.end)}';
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(
        offset: selection.start + tableText.length,
      );
    }
    notifyListeners();
  }

  /// Inserts a code block
  void insertCodeBlock(String code, {String? language}) {
    _saveUndoState();
    final selection = _textController.selection;
    if (selection.isValid) {
      final text = _textController.text;
      final langLabel = language != null ? ' ($language)' : '';
      final codeBlockText = '\n```$langLabel\n$code\n```\n';
      final newText = '${text.substring(0, selection.start)}'
          '$codeBlockText'
          '${text.substring(selection.end)}';
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(
        offset: selection.start + codeBlockText.length,
      );
    }
    notifyListeners();
  }

  /// Inserts a special character or emoji at cursor position
  void insertText(String textToInsert) {
    _saveUndoState();
    final selection = _textController.selection;
    if (selection.isValid) {
      final text = _textController.text;
      final newText = '${text.substring(0, selection.start)}'
          '$textToInsert'
          '${text.substring(selection.end)}';
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(
        offset: selection.start + textToInsert.length,
      );
    }
    notifyListeners();
  }

  /// Sets the font size
  void setFontSize(double? size) {
    _saveUndoState();
    _state = _state.copyWith(
      currentStyle: _state.currentStyle.withFontSize(size),
    );
    notifyListeners();
  }

  /// Gets the current font size
  double? get currentFontSize => _state.currentStyle.fontSize;

  /// Sets the content from HTML
  void setHtml(String html) {
    _saveUndoState();
    _loadHtml(html);
    notifyListeners();
  }

  /// Sets the content from plain text
  void setText(String text) {
    _saveUndoState();
    _textController.text = text;
    notifyListeners();
  }

  /// Clears all content
  void clear() {
    _saveUndoState();
    _textController.clear();
    _state = EditorState.empty();
    notifyListeners();
  }

  /// Requests focus on the editor
  void requestFocus() {
    focusNode.requestFocus();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
