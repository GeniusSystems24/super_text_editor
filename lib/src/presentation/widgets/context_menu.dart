import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../editor/super_editor_controller.dart';

/// Menu item for editor context menu
class EditorContextMenuItem {
  /// The label to display
  final String label;

  /// The icon to display
  final IconData? icon;

  /// The keyboard shortcut hint
  final String? shortcut;

  /// Whether the item is enabled
  final bool enabled;

  /// Whether this is a divider
  final bool isDivider;

  /// The callback when tapped
  final VoidCallback? onTap;

  const EditorContextMenuItem({
    required this.label,
    this.icon,
    this.shortcut,
    this.enabled = true,
    this.isDivider = false,
    this.onTap,
  });

  /// Creates a divider item
  const EditorContextMenuItem.divider()
      : label = '',
        icon = null,
        shortcut = null,
        enabled = false,
        isDivider = true,
        onTap = null;
}

/// Configuration for the context menu
class EditorContextMenuConfig {
  /// Whether to show cut option
  final bool showCut;

  /// Whether to show copy option
  final bool showCopy;

  /// Whether to show paste option
  final bool showPaste;

  /// Whether to show select all option
  final bool showSelectAll;

  /// Whether to show undo/redo options
  final bool showUndoRedo;

  /// Whether to show formatting options
  final bool showFormatting;

  /// Whether to show find option
  final bool showFind;

  /// Custom menu items to add
  final List<EditorContextMenuItem> customItems;

  const EditorContextMenuConfig({
    this.showCut = true,
    this.showCopy = true,
    this.showPaste = true,
    this.showSelectAll = true,
    this.showUndoRedo = true,
    this.showFormatting = true,
    this.showFind = true,
    this.customItems = const [],
  });

  /// Default configuration with all options
  static const EditorContextMenuConfig full = EditorContextMenuConfig();

  /// Basic configuration with only clipboard options
  static const EditorContextMenuConfig basic = EditorContextMenuConfig(
    showUndoRedo: false,
    showFormatting: false,
    showFind: false,
  );
}

/// Context menu for the editor
class EditorContextMenu extends StatelessWidget {
  /// The editor controller
  final SuperEditorController controller;

  /// Menu configuration
  final EditorContextMenuConfig config;

  /// Callback when find is requested
  final VoidCallback? onFind;

  /// Callback when insert link is requested
  final VoidCallback? onInsertLink;

  /// Position to show the menu
  final Offset position;

  /// Callback when menu is dismissed
  final VoidCallback onDismiss;

  const EditorContextMenu({
    super.key,
    required this.controller,
    required this.position,
    required this.onDismiss,
    this.config = const EditorContextMenuConfig(),
    this.onFind,
    this.onInsertLink,
  });

  /// Shows the context menu at the given position
  static Future<void> show(
    BuildContext context, {
    required SuperEditorController controller,
    required Offset position,
    EditorContextMenuConfig config = const EditorContextMenuConfig(),
    VoidCallback? onFind,
    VoidCallback? onInsertLink,
  }) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final items = _buildMenuItems(
      context,
      controller: controller,
      config: config,
      onFind: onFind,
      onInsertLink: onInsertLink,
    );

    await showMenu<void>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      items: items,
      elevation: 8,
    );
  }

  static List<PopupMenuEntry<void>> _buildMenuItems(
    BuildContext context, {
    required SuperEditorController controller,
    required EditorContextMenuConfig config,
    VoidCallback? onFind,
    VoidCallback? onInsertLink,
  }) {
    final List<PopupMenuEntry<void>> items = [];
    final hasSelection = controller.textController.selection.isValid &&
        !controller.textController.selection.isCollapsed;
    final hasText = controller.textController.text.isNotEmpty;

    // Undo/Redo
    if (config.showUndoRedo) {
      items.addAll([
        _buildMenuItem(
          context,
          label: 'Undo',
          icon: Icons.undo,
          shortcut: 'Ctrl+Z',
          enabled: controller.canUndo,
          onTap: () {
            Navigator.pop(context);
            controller.undo();
          },
        ),
        _buildMenuItem(
          context,
          label: 'Redo',
          icon: Icons.redo,
          shortcut: 'Ctrl+Y',
          enabled: controller.canRedo,
          onTap: () {
            Navigator.pop(context);
            controller.redo();
          },
        ),
        const PopupMenuDivider(),
      ]);
    }

    // Clipboard
    if (config.showCut) {
      items.add(_buildMenuItem(
        context,
        label: 'Cut',
        icon: Icons.content_cut,
        shortcut: 'Ctrl+X',
        enabled: hasSelection,
        onTap: () async {
          Navigator.pop(context);
          final selection = controller.textController.selection;
          final text = controller.textController.text
              .substring(selection.start, selection.end);
          await Clipboard.setData(ClipboardData(text: text));
          controller.textController.text =
              controller.textController.text.substring(0, selection.start) +
                  controller.textController.text.substring(selection.end);
          controller.textController.selection = TextSelection.collapsed(
            offset: selection.start,
          );
        },
      ));
    }

    if (config.showCopy) {
      items.add(_buildMenuItem(
        context,
        label: 'Copy',
        icon: Icons.content_copy,
        shortcut: 'Ctrl+C',
        enabled: hasSelection,
        onTap: () async {
          Navigator.pop(context);
          final selection = controller.textController.selection;
          final text = controller.textController.text
              .substring(selection.start, selection.end);
          await Clipboard.setData(ClipboardData(text: text));
        },
      ));
    }

    if (config.showPaste) {
      items.add(_buildMenuItem(
        context,
        label: 'Paste',
        icon: Icons.content_paste,
        shortcut: 'Ctrl+V',
        enabled: true, // Can't easily check clipboard
        onTap: () async {
          Navigator.pop(context);
          final data = await Clipboard.getData(Clipboard.kTextPlain);
          if (data?.text != null) {
            controller.insertText(data!.text!);
          }
        },
      ));
    }

    if (config.showCut || config.showCopy || config.showPaste) {
      items.add(const PopupMenuDivider());
    }

    // Select All
    if (config.showSelectAll) {
      items.add(_buildMenuItem(
        context,
        label: 'Select All',
        icon: Icons.select_all,
        shortcut: 'Ctrl+A',
        enabled: hasText,
        onTap: () {
          Navigator.pop(context);
          controller.textController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.textController.text.length,
          );
        },
      ));
    }

    // Find
    if (config.showFind && onFind != null) {
      items.addAll([
        const PopupMenuDivider(),
        _buildMenuItem(
          context,
          label: 'Find...',
          icon: Icons.search,
          shortcut: 'Ctrl+F',
          enabled: true,
          onTap: () {
            Navigator.pop(context);
            onFind.call();
          },
        ),
      ]);
    }

    // Formatting
    if (config.showFormatting && hasSelection) {
      items.addAll([
        const PopupMenuDivider(),
        _buildMenuItem(
          context,
          label: 'Bold',
          icon: Icons.format_bold,
          shortcut: 'Ctrl+B',
          enabled: true,
          onTap: () {
            Navigator.pop(context);
            controller.toggleFormat(
              const _TextFormatBold().format,
            );
          },
        ),
        _buildMenuItem(
          context,
          label: 'Italic',
          icon: Icons.format_italic,
          shortcut: 'Ctrl+I',
          enabled: true,
          onTap: () {
            Navigator.pop(context);
            controller.toggleFormat(
              const _TextFormatItalic().format,
            );
          },
        ),
        _buildMenuItem(
          context,
          label: 'Underline',
          icon: Icons.format_underlined,
          shortcut: 'Ctrl+U',
          enabled: true,
          onTap: () {
            Navigator.pop(context);
            controller.toggleFormat(
              const _TextFormatUnderline().format,
            );
          },
        ),
      ]);
    }

    // Insert Link
    if (onInsertLink != null && hasSelection) {
      items.addAll([
        const PopupMenuDivider(),
        _buildMenuItem(
          context,
          label: 'Insert Link...',
          icon: Icons.link,
          shortcut: 'Ctrl+K',
          enabled: true,
          onTap: () {
            Navigator.pop(context);
            onInsertLink.call();
          },
        ),
      ]);
    }

    // Custom items
    if (config.customItems.isNotEmpty) {
      items.add(const PopupMenuDivider());
      for (final item in config.customItems) {
        if (item.isDivider) {
          items.add(const PopupMenuDivider());
        } else {
          items.add(_buildMenuItem(
            context,
            label: item.label,
            icon: item.icon,
            shortcut: item.shortcut,
            enabled: item.enabled,
            onTap: () {
              Navigator.pop(context);
              item.onTap?.call();
            },
          ));
        }
      }
    }

    return items;
  }

  static PopupMenuItem<void> _buildMenuItem(
    BuildContext context, {
    required String label,
    IconData? icon,
    String? shortcut,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return PopupMenuItem<void>(
      enabled: enabled,
      onTap: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: enabled
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withValues(alpha: 0.38),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: enabled
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
          ),
          if (shortcut != null) ...[
            const SizedBox(width: 24),
            Text(
              shortcut,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This widget is used for showing context menu via GestureDetector
    return const SizedBox.shrink();
  }
}

// Helper classes for format types
class _TextFormatBold {
  const _TextFormatBold();
  dynamic get format => _getFormat('bold');
}

class _TextFormatItalic {
  const _TextFormatItalic();
  dynamic get format => _getFormat('italic');
}

class _TextFormatUnderline {
  const _TextFormatUnderline();
  dynamic get format => _getFormat('underline');
}

dynamic _getFormat(String name) {
  // Import TextFormat enum dynamically
  switch (name) {
    case 'bold':
      return _TextFormat.bold;
    case 'italic':
      return _TextFormat.italic;
    case 'underline':
      return _TextFormat.underline;
    default:
      return null;
  }
}

// Re-export for internal use
enum _TextFormat { bold, italic, underline, strikethrough, subscript, superscript, code }
