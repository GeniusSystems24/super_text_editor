import 'package:flutter/material.dart';

/// Available font sizes
const List<double> defaultFontSizes = [
  8,
  9,
  10,
  11,
  12,
  14,
  16,
  18,
  20,
  24,
  28,
  32,
  36,
  48,
  72,
];

/// A font size selector widget for the toolbar
class FontSizeSelector extends StatelessWidget {
  /// Current font size (null for default)
  final double? currentSize;

  /// Callback when size changes
  final ValueChanged<double?> onSizeChanged;

  /// Available sizes
  final List<double> sizes;

  /// Whether the selector is enabled
  final bool isEnabled;

  /// Creates a new FontSizeSelector
  const FontSizeSelector({
    super.key,
    this.currentSize,
    required this.onSizeChanged,
    this.sizes = defaultFontSizes,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 70,
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<double?>(
          value: currentSize,
          isExpanded: true,
          isDense: true,
          hint: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('Size'),
          ),
          items: [
            const DropdownMenuItem<double?>(
              value: null,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('Default'),
              ),
            ),
            ...sizes.map((size) {
              return DropdownMenuItem<double?>(
                value: size,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    size.toInt().toString(),
                    style: TextStyle(fontSize: size.clamp(10, 18)),
                  ),
                ),
              );
            }),
          ],
          onChanged: isEnabled ? onSizeChanged : null,
        ),
      ),
    );
  }
}

/// A font family selector widget for the toolbar
class FontFamilySelector extends StatelessWidget {
  /// Current font family (null for default)
  final String? currentFamily;

  /// Callback when family changes
  final ValueChanged<String?> onFamilyChanged;

  /// Available font families
  final List<String> families;

  /// Whether the selector is enabled
  final bool isEnabled;

  /// Default font families
  static const List<String> defaultFamilies = [
    'Default',
    'Arial',
    'Courier New',
    'Georgia',
    'Times New Roman',
    'Trebuchet MS',
    'Verdana',
  ];

  /// Creates a new FontFamilySelector
  const FontFamilySelector({
    super.key,
    this.currentFamily,
    required this.onFamilyChanged,
    this.families = defaultFamilies,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 120,
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: currentFamily,
          isExpanded: true,
          isDense: true,
          hint: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('Font'),
          ),
          items: families.map((family) {
            return DropdownMenuItem<String?>(
              value: family == 'Default' ? null : family,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  family,
                  style: TextStyle(
                    fontFamily: family == 'Default' ? null : family,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
          onChanged: isEnabled ? onFamilyChanged : null,
        ),
      ),
    );
  }
}
