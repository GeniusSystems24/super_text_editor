import 'package:flutter/material.dart';

/// Result from the table size picker
class TableSizeResult {
  final int rows;
  final int columns;

  const TableSizeResult({required this.rows, required this.columns});
}

/// A picker for selecting table dimensions (like CKEditor)
class TableSizePicker extends StatefulWidget {
  /// Maximum number of rows
  final int maxRows;

  /// Maximum number of columns
  final int maxColumns;

  /// Callback when a size is selected
  final ValueChanged<TableSizeResult>? onSizeSelected;

  const TableSizePicker({
    super.key,
    this.maxRows = 10,
    this.maxColumns = 10,
    this.onSizeSelected,
  });

  /// Shows the table size picker as a dialog
  static Future<TableSizeResult?> show(BuildContext context) {
    return showDialog<TableSizeResult>(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Insert Table',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TableSizePicker(
                onSizeSelected: (result) {
                  Navigator.of(context).pop(result);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  State<TableSizePicker> createState() => _TableSizePickerState();
}

class _TableSizePickerState extends State<TableSizePicker> {
  int _hoveredRows = 0;
  int _hoveredCols = 0;
  int _selectedRows = 0;
  int _selectedCols = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Size indicator
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _hoveredRows > 0 && _hoveredCols > 0
                ? '$_hoveredRows × $_hoveredCols'
                : 'Select size',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Grid
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int row = 1; row <= widget.maxRows; row++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int col = 1; col <= widget.maxColumns; col++)
                      _buildCell(row, col, theme),
                  ],
                ),
            ],
          ),
        ),
        // Quick size buttons
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildQuickSizeButton('2×2', 2, 2),
            _buildQuickSizeButton('3×3', 3, 3),
            _buildQuickSizeButton('4×4', 4, 4),
            _buildQuickSizeButton('5×3', 5, 3),
          ],
        ),
      ],
    );
  }

  Widget _buildCell(int row, int col, ThemeData theme) {
    final isHovered = row <= _hoveredRows && col <= _hoveredCols;
    final isSelected = row <= _selectedRows && col <= _selectedCols;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hoveredRows = row;
          _hoveredCols = col;
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRows = row;
            _selectedCols = col;
          });
          widget.onSizeSelected?.call(
            TableSizeResult(rows: row, columns: col),
          );
        },
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : isHovered
                    ? theme.colorScheme.primary.withOpacity(0.3)
                    : theme.colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: isSelected || isHovered
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSizeButton(String label, int rows, int cols) {
    return OutlinedButton(
      onPressed: () {
        widget.onSizeSelected?.call(
          TableSizeResult(rows: rows, columns: cols),
        );
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }
}

/// A compact inline table size picker
class InlineTableSizePicker extends StatefulWidget {
  /// Callback when a size is selected
  final ValueChanged<TableSizeResult>? onSizeSelected;

  const InlineTableSizePicker({
    super.key,
    this.onSizeSelected,
  });

  @override
  State<InlineTableSizePicker> createState() => _InlineTableSizePickerState();
}

class _InlineTableSizePickerState extends State<InlineTableSizePicker> {
  int _hoveredRows = 0;
  int _hoveredCols = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _hoveredRows > 0 && _hoveredCols > 0
                ? '$_hoveredRows × $_hoveredCols'
                : 'Insert Table',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int row = 1; row <= 8; row++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int col = 1; col <= 8; col++) _buildMiniCell(row, col, theme),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCell(int row, int col, ThemeData theme) {
    final isHovered = row <= _hoveredRows && col <= _hoveredCols;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hoveredRows = row;
          _hoveredCols = col;
        });
      },
      onExit: (_) {
        // Keep the hover state for better UX
      },
      child: GestureDetector(
        onTap: () {
          widget.onSizeSelected?.call(
            TableSizeResult(rows: row, columns: col),
          );
        },
        child: Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: isHovered
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: isHovered ? theme.colorScheme.primary : theme.dividerColor,
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
