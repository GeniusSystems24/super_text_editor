import 'package:flutter/material.dart';

/// Dialog result for table insertion
class TableDialogResult {
  /// Number of rows
  final int rows;

  /// Number of columns
  final int columns;

  /// Whether to include a header row
  final bool hasHeader;

  /// Creates a new TableDialogResult
  const TableDialogResult({
    required this.rows,
    required this.columns,
    this.hasHeader = true,
  });
}

/// Dialog for inserting a table
class TableDialog extends StatefulWidget {
  /// Maximum rows allowed
  final int maxRows;

  /// Maximum columns allowed
  final int maxColumns;

  /// Creates a new TableDialog
  const TableDialog({
    super.key,
    this.maxRows = 10,
    this.maxColumns = 10,
  });

  /// Shows the dialog and returns the result
  static Future<TableDialogResult?> show(
    BuildContext context, {
    int maxRows = 10,
    int maxColumns = 10,
  }) {
    return showDialog<TableDialogResult>(
      context: context,
      builder: (context) => TableDialog(
        maxRows: maxRows,
        maxColumns: maxColumns,
      ),
    );
  }

  @override
  State<TableDialog> createState() => _TableDialogState();
}

class _TableDialogState extends State<TableDialog> {
  int _hoveredRows = 0;
  int _hoveredCols = 0;
  int _selectedRows = 2;
  int _selectedCols = 2;
  bool _hasHeader = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Insert Table'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grid picker
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                // Grid
                Column(
                  children: List.generate(widget.maxRows, (row) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(widget.maxColumns, (col) {
                        final isHovered = row < _hoveredRows && col < _hoveredCols;
                        final isSelected = row < _selectedRows && col < _selectedCols;

                        return MouseRegion(
                          onEnter: (_) {
                            setState(() {
                              _hoveredRows = row + 1;
                              _hoveredCols = col + 1;
                            });
                          },
                          onExit: (_) {
                            setState(() {
                              _hoveredRows = 0;
                              _hoveredCols = 0;
                            });
                          },
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRows = row + 1;
                                _selectedCols = col + 1;
                              });
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: isHovered
                                    ? theme.colorScheme.primary.withValues(alpha: 0.3)
                                    : isSelected
                                        ? theme.colorScheme.primary.withValues(alpha: 0.5)
                                        : theme.colorScheme.surfaceContainerHighest,
                                border: Border.all(
                                  color: isHovered || isSelected
                                      ? theme.colorScheme.primary
                                      : theme.dividerColor,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                // Size indicator
                Text(
                  _hoveredRows > 0 && _hoveredCols > 0
                      ? '$_hoveredRows × $_hoveredCols'
                      : '$_selectedRows × $_selectedCols',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Header option
          CheckboxListTile(
            title: const Text('Include header row'),
            value: _hasHeader,
            onChanged: (value) {
              setState(() {
                _hasHeader = value ?? true;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(TableDialogResult(
              rows: _selectedRows,
              columns: _selectedCols,
              hasHeader: _hasHeader,
            ));
          },
          child: const Text('Insert'),
        ),
      ],
    );
  }
}
