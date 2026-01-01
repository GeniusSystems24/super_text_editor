import 'package:flutter/material.dart';

/// A button widget for the editor toolbar
class ToolbarButton extends StatelessWidget {
  /// The icon to display
  final IconData icon;

  /// Tooltip text
  final String? tooltip;

  /// Whether the button is active/selected
  final bool isActive;

  /// Whether the button is enabled
  final bool isEnabled;

  /// Callback when pressed
  final VoidCallback? onPressed;

  /// Icon size
  final double iconSize;

  /// Creates a new ToolbarButton
  const ToolbarButton({
    super.key,
    required this.icon,
    this.tooltip,
    this.isActive = false,
    this.isEnabled = true,
    this.onPressed,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Tooltip(
      message: tooltip ?? '',
      waitDuration: const Duration(milliseconds: 500),
      child: Material(
        color: isActive
            ? colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: iconSize,
              color: isEnabled
                  ? (isActive
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface)
                  : colorScheme.onSurface.withValues(alpha: 0.38),
            ),
          ),
        ),
      ),
    );
  }
}

/// A dropdown button for the toolbar
class ToolbarDropdown<T> extends StatelessWidget {
  /// Current value
  final T value;

  /// Available items
  final List<DropdownMenuItem<T>> items;

  /// Callback when value changes
  final ValueChanged<T?>? onChanged;

  /// Whether the dropdown is enabled
  final bool isEnabled;

  /// Hint text
  final String? hint;

  /// Width of the dropdown
  final double width;

  /// Creates a new ToolbarDropdown
  const ToolbarDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.isEnabled = true,
    this.hint,
    this.width = 120,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: isEnabled ? onChanged : null,
          isExpanded: true,
          isDense: true,
          style: theme.textTheme.bodyMedium,
          hint: hint != null ? Text(hint!) : null,
        ),
      ),
    );
  }
}

/// A color picker button for the toolbar
class ToolbarColorButton extends StatelessWidget {
  /// Current color
  final Color? color;

  /// The icon to display
  final IconData icon;

  /// Tooltip text
  final String? tooltip;

  /// Callback when color is selected
  final ValueChanged<Color?> onColorSelected;

  /// Available colors
  final List<Color> colors;

  /// Creates a new ToolbarColorButton
  const ToolbarColorButton({
    super.key,
    this.color,
    required this.icon,
    this.tooltip,
    required this.onColorSelected,
    this.colors = defaultColors,
  });

  static const List<Color> defaultColors = [
    Colors.black,
    Colors.grey,
    Colors.white,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Color?>(
      tooltip: tooltip ?? '',
      offset: const Offset(0, 36),
      itemBuilder: (context) => [
        PopupMenuItem<Color?>(
          value: null,
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Icon(Icons.block, size: 16, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              const Text('Remove color'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<Color?>(
          enabled: false,
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: colors.map((c) => _ColorBox(
              color: c,
              isSelected: c == color,
              onTap: () {
                Navigator.of(context).pop(c);
              },
            )).toList(),
          ),
        ),
      ],
      onSelected: onColorSelected,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            Container(
              width: 16,
              height: 4,
              color: color ?? Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorBox extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorBox({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// A divider for the toolbar
class ToolbarDivider extends StatelessWidget {
  /// Creates a new ToolbarDivider
  const ToolbarDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Theme.of(context).dividerColor,
    );
  }
}
