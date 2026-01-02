import 'package:flutter/material.dart';
import '../../core/document/nodes.dart';

/// Component for rendering a paragraph node
class ParagraphComponent extends StatelessWidget {
  /// The paragraph node to render
  final ParagraphNode node;

  /// Focus node for this paragraph
  final FocusNode focusNode;

  /// Text editing controller
  final TextEditingController textController;

  /// Whether the editor is read-only
  final bool readOnly;

  /// Callback when text changes
  final ValueChanged<String>? onTextChanged;

  /// Callback when selection changes
  final ValueChanged<TextSelection>? onSelectionChanged;

  /// Callback when Enter is pressed
  final VoidCallback? onSubmitted;

  /// Callback when Backspace is pressed at the beginning
  final VoidCallback? onBackspace;

  const ParagraphComponent({
    super.key,
    required this.node,
    required this.focusNode,
    required this.textController,
    this.readOnly = false,
    this.onTextChanged,
    this.onSelectionChanged,
    this.onSubmitted,
    this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: node.indentLevel * 24.0,
        bottom: 8,
      ),
      child: TextField(
        controller: textController,
        focusNode: focusNode,
        readOnly: readOnly,
        maxLines: null,
        textAlign: _getTextAlign(),
        style: _getTextStyle(theme),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        onChanged: onTextChanged,
        onSubmitted: (_) => onSubmitted?.call(),
      ),
    );
  }

  TextAlign _getTextAlign() {
    switch (node.alignment) {
      case TextAlign.left:
        return TextAlign.left;
      case TextAlign.center:
        return TextAlign.center;
      case TextAlign.right:
        return TextAlign.right;
      case TextAlign.justify:
        return TextAlign.justify;
    }
  }

  TextStyle _getTextStyle(ThemeData theme) {
    final baseStyle = theme.textTheme.bodyLarge ?? const TextStyle();

    double fontSize = baseStyle.fontSize ?? 16;
    FontWeight fontWeight = FontWeight.normal;

    switch (node.blockType) {
      case BlockType.heading1:
        fontSize = 32;
        fontWeight = FontWeight.bold;
        break;
      case BlockType.heading2:
        fontSize = 28;
        fontWeight = FontWeight.bold;
        break;
      case BlockType.heading3:
        fontSize = 24;
        fontWeight = FontWeight.bold;
        break;
      case BlockType.heading4:
        fontSize = 20;
        fontWeight = FontWeight.bold;
        break;
      case BlockType.heading5:
        fontSize = 18;
        fontWeight = FontWeight.bold;
        break;
      case BlockType.heading6:
        fontSize = 16;
        fontWeight = FontWeight.bold;
        break;
      case BlockType.blockquote:
        return baseStyle.copyWith(
          fontSize: fontSize,
          fontStyle: FontStyle.italic,
          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
        );
      case BlockType.preformatted:
        return baseStyle.copyWith(
          fontFamily: 'monospace',
          fontSize: 14,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        );
      case BlockType.paragraph:
        break;
    }

    return baseStyle.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
}
