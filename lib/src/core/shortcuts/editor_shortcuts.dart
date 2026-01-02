import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/enums/text_format.dart';
import '../../presentation/editor/super_editor_controller.dart';

/// Defines keyboard shortcuts for the editor
class EditorShortcuts {
  EditorShortcuts._();

  /// Default keyboard shortcuts map
  static Map<ShortcutActivator, Intent> get defaultShortcuts => {
        // Text formatting
        const SingleActivator(LogicalKeyboardKey.keyB, control: true):
            const FormatIntent(TextFormat.bold),
        const SingleActivator(LogicalKeyboardKey.keyI, control: true):
            const FormatIntent(TextFormat.italic),
        const SingleActivator(LogicalKeyboardKey.keyU, control: true):
            const FormatIntent(TextFormat.underline),
        const SingleActivator(LogicalKeyboardKey.keyS, control: true, shift: true):
            const FormatIntent(TextFormat.strikethrough),

        // Mac variants
        const SingleActivator(LogicalKeyboardKey.keyB, meta: true):
            const FormatIntent(TextFormat.bold),
        const SingleActivator(LogicalKeyboardKey.keyI, meta: true):
            const FormatIntent(TextFormat.italic),
        const SingleActivator(LogicalKeyboardKey.keyU, meta: true):
            const FormatIntent(TextFormat.underline),

        // Undo/Redo
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
            const UndoIntent(),
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true):
            const RedoIntent(),
        const SingleActivator(LogicalKeyboardKey.keyY, control: true):
            const RedoIntent(),
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true):
            const UndoIntent(),
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true):
            const RedoIntent(),

        // Find & Replace
        const SingleActivator(LogicalKeyboardKey.keyF, control: true):
            const FindIntent(),
        const SingleActivator(LogicalKeyboardKey.keyH, control: true):
            const ReplaceIntent(),
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true):
            const FindIntent(),
        const SingleActivator(LogicalKeyboardKey.keyH, meta: true):
            const ReplaceIntent(),

        // Save
        const SingleActivator(LogicalKeyboardKey.keyS, control: true):
            const SaveIntent(),
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true):
            const SaveIntent(),

        // Select All
        const SingleActivator(LogicalKeyboardKey.keyA, control: true):
            const SelectAllIntent(),
        const SingleActivator(LogicalKeyboardKey.keyA, meta: true):
            const SelectAllIntent(),

        // Clear formatting
        const SingleActivator(LogicalKeyboardKey.backslash, control: true):
            const ClearFormattingIntent(),
        const SingleActivator(LogicalKeyboardKey.backslash, meta: true):
            const ClearFormattingIntent(),

        // Insert link
        const SingleActivator(LogicalKeyboardKey.keyK, control: true):
            const InsertLinkIntent(),
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            const InsertLinkIntent(),
      };
}

/// Intent for text formatting
class FormatIntent extends Intent {
  final TextFormat format;
  const FormatIntent(this.format);
}

/// Intent for undo
class UndoIntent extends Intent {
  const UndoIntent();
}

/// Intent for redo
class RedoIntent extends Intent {
  const RedoIntent();
}

/// Intent for find
class FindIntent extends Intent {
  const FindIntent();
}

/// Intent for replace
class ReplaceIntent extends Intent {
  const ReplaceIntent();
}

/// Intent for save
class SaveIntent extends Intent {
  const SaveIntent();
}

/// Intent for select all
class SelectAllIntent extends Intent {
  const SelectAllIntent();
}

/// Intent for clear formatting
class ClearFormattingIntent extends Intent {
  const ClearFormattingIntent();
}

/// Intent for insert link
class InsertLinkIntent extends Intent {
  const InsertLinkIntent();
}

/// Action handler for editor shortcuts
class EditorShortcutActions {
  final SuperEditorController controller;
  final VoidCallback? onFind;
  final VoidCallback? onReplace;
  final VoidCallback? onSave;
  final VoidCallback? onInsertLink;

  EditorShortcutActions({
    required this.controller,
    this.onFind,
    this.onReplace,
    this.onSave,
    this.onInsertLink,
  });

  /// Returns the action map for shortcuts
  Map<Type, Action<Intent>> get actions => {
        FormatIntent: CallbackAction<FormatIntent>(
          onInvoke: (intent) {
            controller.toggleFormat(intent.format);
            return null;
          },
        ),
        UndoIntent: CallbackAction<UndoIntent>(
          onInvoke: (_) {
            controller.undo();
            return null;
          },
        ),
        RedoIntent: CallbackAction<RedoIntent>(
          onInvoke: (_) {
            controller.redo();
            return null;
          },
        ),
        FindIntent: CallbackAction<FindIntent>(
          onInvoke: (_) {
            onFind?.call();
            return null;
          },
        ),
        ReplaceIntent: CallbackAction<ReplaceIntent>(
          onInvoke: (_) {
            onReplace?.call();
            return null;
          },
        ),
        SaveIntent: CallbackAction<SaveIntent>(
          onInvoke: (_) {
            onSave?.call();
            return null;
          },
        ),
        SelectAllIntent: CallbackAction<SelectAllIntent>(
          onInvoke: (_) {
            controller.textController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.textController.text.length,
            );
            return null;
          },
        ),
        ClearFormattingIntent: CallbackAction<ClearFormattingIntent>(
          onInvoke: (_) {
            controller.clearFormatting();
            return null;
          },
        ),
        InsertLinkIntent: CallbackAction<InsertLinkIntent>(
          onInvoke: (_) {
            onInsertLink?.call();
            return null;
          },
        ),
      };
}

/// Widget that wraps editor with keyboard shortcuts
class EditorShortcutsWrapper extends StatelessWidget {
  final Widget child;
  final SuperEditorController controller;
  final VoidCallback? onFind;
  final VoidCallback? onReplace;
  final VoidCallback? onSave;
  final VoidCallback? onInsertLink;
  final Map<ShortcutActivator, Intent>? additionalShortcuts;

  const EditorShortcutsWrapper({
    super.key,
    required this.child,
    required this.controller,
    this.onFind,
    this.onReplace,
    this.onSave,
    this.onInsertLink,
    this.additionalShortcuts,
  });

  @override
  Widget build(BuildContext context) {
    final shortcuts = Map<ShortcutActivator, Intent>.from(
      EditorShortcuts.defaultShortcuts,
    );
    if (additionalShortcuts != null) {
      shortcuts.addAll(additionalShortcuts!);
    }

    final actionHandler = EditorShortcutActions(
      controller: controller,
      onFind: onFind,
      onReplace: onReplace,
      onSave: onSave,
      onInsertLink: onInsertLink,
    );

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: actionHandler.actions,
        child: child,
      ),
    );
  }
}
