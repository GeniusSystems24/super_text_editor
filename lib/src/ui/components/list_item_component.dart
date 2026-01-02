import 'package:flutter/material.dart';
import '../../core/document/nodes.dart';

/// Component for rendering a list item node
class ListItemComponent extends StatelessWidget {
  /// The list item node to render
  final ListItemNode node;

  /// Focus node for this list item
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

  /// The item number (for numbered lists)
  final int? itemNumber;

  const ListItemComponent({
    super.key,
    required this.node,
    required this.focusNode,
    required this.textController,
    this.readOnly = false,
    this.onTextChanged,
    this.onSelectionChanged,
    this.onSubmitted,
    this.onBackspace,
    this.itemNumber,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: node.indentLevel * 24.0,
        bottom: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bullet or number
          SizedBox(
            width: 24,
            child: _buildMarker(theme),
          ),
          // Content
          Expanded(
            child: TextField(
              controller: textController,
              focusNode: focusNode,
              readOnly: readOnly,
              maxLines: null,
              style: theme.textTheme.bodyLarge,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: onTextChanged,
              onSubmitted: (_) => onSubmitted?.call(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarker(ThemeData theme) {
    if (node.listType == ListType.numbered) {
      return Text(
        '${itemNumber ?? 1}.',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface,
            shape: BoxShape.circle,
          ),
        ),
      );
    }
  }
}
