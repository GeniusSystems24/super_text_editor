import 'package:flutter/material.dart';
import '../../core/document/nodes.dart';
import '../editor/document_editor.dart';
import '../pickers/table_size_picker.dart';

/// Configuration for the editor toolbar
class EditorToolbarConfig {
  /// Show text formatting buttons (bold, italic, underline, strikethrough)
  final bool showTextFormatting;

  /// Show heading buttons
  final bool showHeadings;

  /// Show alignment buttons
  final bool showAlignment;

  /// Show list buttons
  final bool showLists;

  /// Show link button
  final bool showLink;

  /// Show image button
  final bool showImage;

  /// Show table button
  final bool showTable;

  /// Show undo/redo buttons
  final bool showUndoRedo;

  const EditorToolbarConfig({
    this.showTextFormatting = true,
    this.showHeadings = true,
    this.showAlignment = true,
    this.showLists = true,
    this.showLink = true,
    this.showImage = true,
    this.showTable = true,
    this.showUndoRedo = true,
  });
}

/// The editor toolbar widget
class EditorToolbar extends StatelessWidget {
  /// The editor controller
  final DocumentEditorController controller;

  /// Toolbar configuration
  final EditorToolbarConfig config;

  /// Callback when link button is pressed
  final VoidCallback? onInsertLink;

  /// Callback when image button is pressed
  final VoidCallback? onInsertImage;

  const EditorToolbar({
    super.key,
    required this.controller,
    this.config = const EditorToolbarConfig(),
    this.onInsertLink,
    this.onInsertImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Undo/Redo
            if (config.showUndoRedo) ...[
              _ToolbarIconButton(
                icon: Icons.undo,
                tooltip: 'Undo',
                onPressed: controller.canUndo ? controller.undo : null,
              ),
              _ToolbarIconButton(
                icon: Icons.redo,
                tooltip: 'Redo',
                onPressed: controller.canRedo ? controller.redo : null,
              ),
              const _ToolbarDivider(),
            ],

            // Text formatting
            if (config.showTextFormatting) ...[
              _ToolbarIconButton(
                icon: Icons.format_bold,
                tooltip: 'Bold (Ctrl+B)',
                onPressed: controller.toggleBold,
              ),
              _ToolbarIconButton(
                icon: Icons.format_italic,
                tooltip: 'Italic (Ctrl+I)',
                onPressed: controller.toggleItalic,
              ),
              _ToolbarIconButton(
                icon: Icons.format_underlined,
                tooltip: 'Underline (Ctrl+U)',
                onPressed: controller.toggleUnderline,
              ),
              _ToolbarIconButton(
                icon: Icons.format_strikethrough,
                tooltip: 'Strikethrough',
                onPressed: controller.toggleStrikethrough,
              ),
              const _ToolbarDivider(),
            ],

            // Headings
            if (config.showHeadings) ...[
              _HeadingDropdown(controller: controller),
              const _ToolbarDivider(),
            ],

            // Alignment
            if (config.showAlignment) ...[
              _ToolbarIconButton(
                icon: Icons.format_align_left,
                tooltip: 'Align Left',
                onPressed: () => controller.setAlignment(TextAlign.left),
              ),
              _ToolbarIconButton(
                icon: Icons.format_align_center,
                tooltip: 'Align Center',
                onPressed: () => controller.setAlignment(TextAlign.center),
              ),
              _ToolbarIconButton(
                icon: Icons.format_align_right,
                tooltip: 'Align Right',
                onPressed: () => controller.setAlignment(TextAlign.right),
              ),
              _ToolbarIconButton(
                icon: Icons.format_align_justify,
                tooltip: 'Justify',
                onPressed: () => controller.setAlignment(TextAlign.justify),
              ),
              const _ToolbarDivider(),
            ],

            // Lists
            if (config.showLists) ...[
              _ToolbarIconButton(
                icon: Icons.format_list_bulleted,
                tooltip: 'Bullet List',
                onPressed: controller.toggleBulletList,
              ),
              _ToolbarIconButton(
                icon: Icons.format_list_numbered,
                tooltip: 'Numbered List',
                onPressed: controller.toggleNumberedList,
              ),
              const _ToolbarDivider(),
            ],

            // Link
            if (config.showLink) ...[
              _ToolbarIconButton(
                icon: Icons.link,
                tooltip: 'Insert Link',
                onPressed: onInsertLink,
              ),
            ],

            // Image
            if (config.showImage) ...[
              _ToolbarIconButton(
                icon: Icons.image,
                tooltip: 'Insert Image',
                onPressed: onInsertImage,
              ),
            ],

            // Table
            if (config.showTable) ...[
              _TableButton(controller: controller),
            ],
          ],
        ),
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isActive;

  const _ToolbarIconButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive ? theme.colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 20,
              color: onPressed == null
                  ? theme.disabledColor
                  : isActive
                      ? theme.colorScheme.primary
                      : theme.iconTheme.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Theme.of(context).dividerColor,
    );
  }
}

class _HeadingDropdown extends StatelessWidget {
  final DocumentEditorController controller;

  const _HeadingDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<BlockType>(
      tooltip: 'Paragraph Style',
      itemBuilder: (context) => [
        _buildMenuItem(BlockType.paragraph, 'Paragraph', theme),
        _buildMenuItem(BlockType.heading1, 'Heading 1', theme, fontSize: 24),
        _buildMenuItem(BlockType.heading2, 'Heading 2', theme, fontSize: 22),
        _buildMenuItem(BlockType.heading3, 'Heading 3', theme, fontSize: 20),
        _buildMenuItem(BlockType.heading4, 'Heading 4', theme, fontSize: 18),
        _buildMenuItem(BlockType.heading5, 'Heading 5', theme, fontSize: 16),
        _buildMenuItem(BlockType.heading6, 'Heading 6', theme, fontSize: 14),
        _buildMenuItem(BlockType.blockquote, 'Blockquote', theme),
        _buildMenuItem(BlockType.preformatted, 'Preformatted', theme),
      ],
      onSelected: controller.setBlockType,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Paragraph',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<BlockType> _buildMenuItem(
    BlockType type,
    String label,
    ThemeData theme, {
    double? fontSize,
  }) {
    return PopupMenuItem<BlockType>(
      value: type,
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: fontSize,
          fontWeight: type != BlockType.paragraph ? FontWeight.bold : null,
          fontStyle: type == BlockType.blockquote ? FontStyle.italic : null,
          fontFamily: type == BlockType.preformatted ? 'monospace' : null,
        ),
      ),
    );
  }
}

class _TableButton extends StatelessWidget {
  final DocumentEditorController controller;

  const _TableButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      tooltip: 'Insert Table',
      itemBuilder: (context) => [
        PopupMenuItem<void>(
          enabled: false,
          child: InlineTableSizePicker(
            onSizeSelected: (result) {
              Navigator.of(context).pop();
              controller.insertTable(result.rows, result.columns);
            },
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.table_chart,
              size: 20,
              color: Theme.of(context).iconTheme.color,
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }
}
