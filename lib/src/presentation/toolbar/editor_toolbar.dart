import 'package:flutter/material.dart';
import '../../domain/enums/list_type.dart';
import '../../domain/enums/paragraph_type.dart';
import '../../domain/enums/text_alignment.dart';
import '../../domain/enums/text_format.dart';
import '../editor/super_editor_controller.dart';
import 'toolbar_button.dart';

/// Configuration for the editor toolbar
class EditorToolbarConfig {
  /// Whether to show undo/redo buttons
  final bool showUndoRedo;

  /// Whether to show paragraph style dropdown
  final bool showParagraphStyle;

  /// Whether to show font size selector
  final bool showFontSize;

  /// Whether to show text formatting buttons
  final bool showTextFormatting;

  /// Whether to show text color button
  final bool showTextColor;

  /// Whether to show highlight color button
  final bool showHighlightColor;

  /// Whether to show alignment buttons
  final bool showAlignment;

  /// Whether to show list buttons
  final bool showLists;

  /// Whether to show indent buttons
  final bool showIndent;

  /// Whether to show link button
  final bool showLink;

  /// Whether to show image button
  final bool showImage;

  /// Whether to show table button
  final bool showTable;

  /// Whether to show code block button
  final bool showCodeBlock;

  /// Whether to show horizontal rule button
  final bool showHorizontalRule;

  /// Whether to show emoji button
  final bool showEmoji;

  /// Whether to show special characters button
  final bool showSpecialChars;

  /// Whether to show clear formatting button
  final bool showClearFormatting;

  /// Whether to show source code button
  final bool showSourceCode;

  /// Creates a new EditorToolbarConfig
  const EditorToolbarConfig({
    this.showUndoRedo = true,
    this.showParagraphStyle = true,
    this.showFontSize = true,
    this.showTextFormatting = true,
    this.showTextColor = true,
    this.showHighlightColor = true,
    this.showAlignment = true,
    this.showLists = true,
    this.showIndent = true,
    this.showLink = true,
    this.showImage = true,
    this.showTable = true,
    this.showCodeBlock = true,
    this.showHorizontalRule = true,
    this.showEmoji = true,
    this.showSpecialChars = true,
    this.showClearFormatting = true,
    this.showSourceCode = false,
  });

  /// Full toolbar with all features
  static const EditorToolbarConfig full = EditorToolbarConfig();

  /// Basic toolbar with only text formatting
  static const EditorToolbarConfig basic = EditorToolbarConfig(
    showParagraphStyle: false,
    showFontSize: false,
    showAlignment: false,
    showLists: false,
    showIndent: false,
    showLink: false,
    showImage: false,
    showTable: false,
    showCodeBlock: false,
    showHorizontalRule: false,
    showEmoji: false,
    showSpecialChars: false,
    showSourceCode: false,
  );

  /// Minimal toolbar
  static const EditorToolbarConfig minimal = EditorToolbarConfig(
    showUndoRedo: false,
    showParagraphStyle: false,
    showFontSize: false,
    showTextColor: false,
    showHighlightColor: false,
    showAlignment: false,
    showLists: false,
    showIndent: false,
    showLink: false,
    showImage: false,
    showTable: false,
    showCodeBlock: false,
    showHorizontalRule: false,
    showEmoji: false,
    showSpecialChars: false,
    showClearFormatting: false,
    showSourceCode: false,
  );
}

/// The main editor toolbar widget
class EditorToolbar extends StatelessWidget {
  /// The editor controller
  final SuperEditorController controller;

  /// Toolbar configuration
  final EditorToolbarConfig config;

  /// Callback when link insertion is requested
  final VoidCallback? onInsertLink;

  /// Callback when image insertion is requested
  final VoidCallback? onInsertImage;

  /// Callback when table insertion is requested
  final VoidCallback? onInsertTable;

  /// Callback when code block insertion is requested
  final VoidCallback? onInsertCodeBlock;

  /// Callback when emoji insertion is requested
  final VoidCallback? onInsertEmoji;

  /// Callback when special character insertion is requested
  final VoidCallback? onInsertSpecialChar;

  /// Callback when source code view is toggled
  final VoidCallback? onToggleSource;

  /// Whether source view is active
  final bool isSourceView;

  /// Creates a new EditorToolbar
  const EditorToolbar({
    super.key,
    required this.controller,
    this.config = const EditorToolbarConfig(),
    this.onInsertLink,
    this.onInsertImage,
    this.onInsertTable,
    this.onInsertCodeBlock,
    this.onInsertEmoji,
    this.onInsertSpecialChar,
    this.onToggleSource,
    this.isSourceView = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => _buildToolbar(context),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final List<Widget> items = [];

    // Undo/Redo
    if (config.showUndoRedo) {
      items.addAll([
        ToolbarButton(
          icon: Icons.undo,
          tooltip: 'Undo',
          isEnabled: controller.canUndo,
          onPressed: controller.undo,
        ),
        ToolbarButton(
          icon: Icons.redo,
          tooltip: 'Redo',
          isEnabled: controller.canRedo,
          onPressed: controller.redo,
        ),
        const ToolbarDivider(),
      ]);
    }

    // Paragraph style
    if (config.showParagraphStyle) {
      items.addAll([
        ToolbarDropdown<ParagraphType>(
          value: controller.currentParagraphType,
          items: ParagraphType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(
                type.displayName,
                style: _getParagraphStyle(type),
              ),
            );
          }).toList(),
          onChanged: (type) {
            if (type != null) controller.setParagraphType(type);
          },
        ),
        const ToolbarDivider(),
      ]);
    }

    // Text formatting
    if (config.showTextFormatting) {
      items.addAll([
        ToolbarButton(
          icon: Icons.format_bold,
          tooltip: 'Bold',
          isActive: controller.isFormatActive(TextFormat.bold),
          onPressed: () => controller.toggleFormat(TextFormat.bold),
        ),
        ToolbarButton(
          icon: Icons.format_italic,
          tooltip: 'Italic',
          isActive: controller.isFormatActive(TextFormat.italic),
          onPressed: () => controller.toggleFormat(TextFormat.italic),
        ),
        ToolbarButton(
          icon: Icons.format_underlined,
          tooltip: 'Underline',
          isActive: controller.isFormatActive(TextFormat.underline),
          onPressed: () => controller.toggleFormat(TextFormat.underline),
        ),
        ToolbarButton(
          icon: Icons.format_strikethrough,
          tooltip: 'Strikethrough',
          isActive: controller.isFormatActive(TextFormat.strikethrough),
          onPressed: () => controller.toggleFormat(TextFormat.strikethrough),
        ),
        ToolbarButton(
          icon: Icons.subscript,
          tooltip: 'Subscript',
          isActive: controller.isFormatActive(TextFormat.subscript),
          onPressed: () => controller.toggleFormat(TextFormat.subscript),
        ),
        ToolbarButton(
          icon: Icons.superscript,
          tooltip: 'Superscript',
          isActive: controller.isFormatActive(TextFormat.superscript),
          onPressed: () => controller.toggleFormat(TextFormat.superscript),
        ),
        const ToolbarDivider(),
      ]);
    }

    // Text color
    if (config.showTextColor) {
      items.add(
        ToolbarColorButton(
          icon: Icons.format_color_text,
          tooltip: 'Text Color',
          color: controller.currentStyle.textColor,
          onColorSelected: controller.setTextColor,
        ),
      );
    }

    // Highlight color
    if (config.showHighlightColor) {
      items.addAll([
        ToolbarColorButton(
          icon: Icons.highlight,
          tooltip: 'Highlight Color',
          color: controller.currentStyle.backgroundColor,
          onColorSelected: controller.setBackgroundColor,
        ),
        const ToolbarDivider(),
      ]);
    }

    // Alignment
    if (config.showAlignment) {
      items.addAll([
        ToolbarButton(
          icon: Icons.format_align_left,
          tooltip: 'Align Left',
          isActive: controller.currentAlignment == TextAlignment.left,
          onPressed: () => controller.setAlignment(TextAlignment.left),
        ),
        ToolbarButton(
          icon: Icons.format_align_center,
          tooltip: 'Center',
          isActive: controller.currentAlignment == TextAlignment.center,
          onPressed: () => controller.setAlignment(TextAlignment.center),
        ),
        ToolbarButton(
          icon: Icons.format_align_right,
          tooltip: 'Align Right',
          isActive: controller.currentAlignment == TextAlignment.right,
          onPressed: () => controller.setAlignment(TextAlignment.right),
        ),
        ToolbarButton(
          icon: Icons.format_align_justify,
          tooltip: 'Justify',
          isActive: controller.currentAlignment == TextAlignment.justify,
          onPressed: () => controller.setAlignment(TextAlignment.justify),
        ),
        const ToolbarDivider(),
      ]);
    }

    // Lists
    if (config.showLists) {
      items.addAll([
        ToolbarButton(
          icon: Icons.format_list_bulleted,
          tooltip: 'Bulleted List',
          isActive: controller.currentListType == ListType.bullet,
          onPressed: () => controller.setListType(
            controller.currentListType == ListType.bullet
                ? ListType.none
                : ListType.bullet,
          ),
        ),
        _buildNumberedListButton(),
        const ToolbarDivider(),
      ]);
    }

    // Indent
    if (config.showIndent) {
      items.addAll([
        ToolbarButton(
          icon: Icons.format_indent_decrease,
          tooltip: 'Decrease Indent',
          onPressed: controller.outdent,
        ),
        ToolbarButton(
          icon: Icons.format_indent_increase,
          tooltip: 'Increase Indent',
          onPressed: controller.indent,
        ),
        const ToolbarDivider(),
      ]);
    }

    // Insert items
    if (config.showLink) {
      items.add(
        ToolbarButton(
          icon: Icons.link,
          tooltip: 'Insert Link',
          onPressed: onInsertLink,
        ),
      );
    }

    if (config.showImage) {
      items.add(
        ToolbarButton(
          icon: Icons.image,
          tooltip: 'Insert Image',
          onPressed: onInsertImage,
        ),
      );
    }

    if (config.showTable) {
      items.add(
        ToolbarButton(
          icon: Icons.table_chart,
          tooltip: 'Insert Table',
          onPressed: onInsertTable,
        ),
      );
    }

    if (config.showCodeBlock) {
      items.add(
        ToolbarButton(
          icon: Icons.code,
          tooltip: 'Insert Code Block',
          onPressed: onInsertCodeBlock,
        ),
      );
    }

    if (config.showHorizontalRule) {
      items.add(
        ToolbarButton(
          icon: Icons.horizontal_rule,
          tooltip: 'Insert Horizontal Line',
          onPressed: controller.insertHorizontalRule,
        ),
      );
    }

    if (config.showEmoji) {
      items.add(
        ToolbarButton(
          icon: Icons.emoji_emotions,
          tooltip: 'Insert Emoji',
          onPressed: onInsertEmoji,
        ),
      );
    }

    if (config.showSpecialChars) {
      items.add(
        ToolbarButton(
          icon: Icons.calculate,
          tooltip: 'Special Characters',
          onPressed: onInsertSpecialChar,
        ),
      );
    }

    if (config.showLink ||
        config.showImage ||
        config.showTable ||
        config.showCodeBlock ||
        config.showHorizontalRule ||
        config.showEmoji ||
        config.showSpecialChars) {
      items.add(const ToolbarDivider());
    }

    // Clear formatting
    if (config.showClearFormatting) {
      items.add(
        ToolbarButton(
          icon: Icons.format_clear,
          tooltip: 'Clear Formatting',
          onPressed: controller.clearFormatting,
        ),
      );
    }

    // Source code view
    if (config.showSourceCode) {
      items.add(
        ToolbarButton(
          icon: Icons.code,
          tooltip: 'Source Code',
          isActive: isSourceView,
          onPressed: onToggleSource,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Wrap(
        spacing: 2,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: items,
      ),
    );
  }

  Widget _buildNumberedListButton() {
    return PopupMenuButton<ListType>(
      tooltip: 'Numbered List',
      offset: const Offset(0, 36),
      itemBuilder: (context) => [
        _buildListTypeItem(ListType.decimal, '1, 2, 3', Icons.format_list_numbered),
        _buildListTypeItem(ListType.decimalLeadingZero, '01, 02, 03', Icons.format_list_numbered),
        _buildListTypeItem(ListType.lowerRoman, 'i, ii, iii', Icons.format_list_numbered),
        _buildListTypeItem(ListType.upperRoman, 'I, II, III', Icons.format_list_numbered),
        _buildListTypeItem(ListType.lowerAlpha, 'a, b, c', Icons.format_list_numbered),
        _buildListTypeItem(ListType.upperAlpha, 'A, B, C', Icons.format_list_numbered),
      ],
      onSelected: (type) {
        controller.setListType(
          controller.currentListType == type ? ListType.none : type,
        );
      },
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: controller.currentListType.isOrdered
              ? Theme.of(controller.focusNode.context ?? controller.focusNode.context!).colorScheme.primaryContainer
              : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.format_list_numbered, size: 20),
      ),
    );
  }

  PopupMenuItem<ListType> _buildListTypeItem(
    ListType type,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem(
      value: type,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: controller.currentListType == type ? Colors.blue : null,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  TextStyle? _getParagraphStyle(ParagraphType type) {
    switch (type) {
      case ParagraphType.heading1:
        return const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
      case ParagraphType.heading2:
        return const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
      case ParagraphType.heading3:
        return const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
      case ParagraphType.heading4:
        return const TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
      case ParagraphType.heading5:
        return const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
      case ParagraphType.heading6:
        return const TextStyle(fontSize: 11, fontWeight: FontWeight.bold);
      case ParagraphType.preformatted:
        return const TextStyle(fontFamily: 'monospace');
      case ParagraphType.blockquote:
        return const TextStyle(fontStyle: FontStyle.italic);
      default:
        return null;
    }
  }
}
