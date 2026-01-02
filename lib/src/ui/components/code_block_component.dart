import 'package:flutter/material.dart';
import '../../core/document/nodes.dart';

/// Component for rendering a code block node
class CodeBlockComponent extends StatelessWidget {
  /// The code block node to render
  final CodeBlockNode node;

  /// Focus node for this code block
  final FocusNode focusNode;

  /// Text editing controller
  final TextEditingController textController;

  /// Whether the editor is read-only
  final bool readOnly;

  /// Callback when code changes
  final ValueChanged<String>? onCodeChanged;

  /// Whether the code block is selected
  final bool isSelected;

  const CodeBlockComponent({
    super.key,
    required this.node,
    required this.focusNode,
    required this.textController,
    this.readOnly = false,
    this.onCodeChanged,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Language header
          if (node.language != null && node.language!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(7),
                  topRight: Radius.circular(7),
                ),
              ),
              child: Text(
                node.language!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          // Code content
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: textController,
              focusNode: focusNode,
              readOnly: readOnly,
              maxLines: null,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: onCodeChanged,
            ),
          ),
        ],
      ),
    );
  }
}
