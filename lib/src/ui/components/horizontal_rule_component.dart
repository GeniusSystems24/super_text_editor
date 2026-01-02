import 'package:flutter/material.dart';
import '../../core/document/nodes.dart';

/// Component for rendering a horizontal rule node
class HorizontalRuleComponent extends StatelessWidget {
  /// The horizontal rule node
  final HorizontalRuleNode node;

  /// Callback when the rule is tapped
  final VoidCallback? onTap;

  /// Whether the rule is selected
  final bool isSelected;

  const HorizontalRuleComponent({
    super.key,
    required this.node,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Divider(
          thickness: 2,
          color: theme.dividerColor,
        ),
      ),
    );
  }
}
