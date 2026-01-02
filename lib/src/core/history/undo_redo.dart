import '../commands/editor_command.dart';

/// Manages undo/redo history for the editor
class EditorHistory {
  /// The maximum number of commands to keep in history
  final int maxHistorySize;

  /// The undo stack
  final List<EditorCommand> _undoStack = [];

  /// The redo stack
  final List<EditorCommand> _redoStack = [];

  /// Creates a new editor history
  EditorHistory({this.maxHistorySize = 100});

  /// Whether undo is available
  bool get canUndo => _undoStack.isNotEmpty;

  /// Whether redo is available
  bool get canRedo => _redoStack.isNotEmpty;

  /// The number of commands in the undo stack
  int get undoCount => _undoStack.length;

  /// The number of commands in the redo stack
  int get redoCount => _redoStack.length;

  /// Executes a command and adds it to history
  void execute(EditorCommand command, EditorContext context) {
    command.execute(context);

    // Try to merge with the last command
    if (_undoStack.isNotEmpty && _undoStack.last.canMergeWith(command)) {
      final merged = _undoStack.removeLast().mergeWith(command);
      _undoStack.add(merged);
    } else {
      _undoStack.add(command);
    }

    // Clear redo stack when a new command is executed
    _redoStack.clear();

    // Trim history if it exceeds max size
    while (_undoStack.length > maxHistorySize) {
      _undoStack.removeAt(0);
    }
  }

  /// Undoes the last command
  void undo(EditorContext context) {
    if (!canUndo) return;

    final command = _undoStack.removeLast();
    command.undo(context);
    _redoStack.add(command);
  }

  /// Redoes the last undone command
  void redo(EditorContext context) {
    if (!canRedo) return;

    final command = _redoStack.removeLast();
    command.execute(context);
    _undoStack.add(command);
  }

  /// Clears all history
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }

  /// Gets a description of the command that would be undone
  String? get undoDescription => _undoStack.isNotEmpty ? _undoStack.last.description : null;

  /// Gets a description of the command that would be redone
  String? get redoDescription => _redoStack.isNotEmpty ? _redoStack.last.description : null;
}

/// A batch of commands that are executed/undone together
class BatchCommand extends EditorCommand {
  final List<EditorCommand> commands;
  final String _description;

  BatchCommand(this.commands, {String description = 'Batch operation'}) : _description = description;

  @override
  String get description => _description;

  @override
  void execute(EditorContext context) {
    for (final command in commands) {
      command.execute(context);
    }
  }

  @override
  void undo(EditorContext context) {
    // Undo in reverse order
    for (int i = commands.length - 1; i >= 0; i--) {
      commands[i].undo(context);
    }
  }
}
