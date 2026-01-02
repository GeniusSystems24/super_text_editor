import 'package:flutter/material.dart';
import '../../core/document/nodes.dart';

/// Component for rendering a table node
class TableComponent extends StatefulWidget {
  /// The table node to render
  final TableNode node;

  /// Whether the editor is read-only
  final bool readOnly;

  /// Callback when a cell's content changes
  final void Function(int row, int col, String text)? onCellChanged;

  /// Callback when a cell is focused
  final void Function(int row, int col)? onCellFocused;

  /// Callback to add a row
  final void Function(bool above)? onAddRow;

  /// Callback to add a column
  final void Function(bool left)? onAddColumn;

  /// Callback to delete a row
  final VoidCallback? onDeleteRow;

  /// Callback to delete a column
  final VoidCallback? onDeleteColumn;

  /// Whether the table is selected
  final bool isSelected;

  const TableComponent({
    super.key,
    required this.node,
    this.readOnly = false,
    this.onCellChanged,
    this.onCellFocused,
    this.onAddRow,
    this.onAddColumn,
    this.onDeleteRow,
    this.onDeleteColumn,
    this.isSelected = false,
  });

  @override
  State<TableComponent> createState() => _TableComponentState();
}

class _TableComponentState extends State<TableComponent> {
  int? _focusedRow;
  int? _focusedCol;
  final Map<String, TextEditingController> _cellControllers = {};
  final Map<String, FocusNode> _cellFocusNodes = {};

  @override
  void dispose() {
    for (final controller in _cellControllers.values) {
      controller.dispose();
    }
    for (final focusNode in _cellFocusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String _cellKey(int row, int col) => '$row-$col';

  TextEditingController _getController(int row, int col) {
    final key = _cellKey(row, col);
    if (!_cellControllers.containsKey(key)) {
      final cell = widget.node.getCell(row, col);
      _cellControllers[key] = TextEditingController(text: cell.plainText);
    }
    return _cellControllers[key]!;
  }

  FocusNode _getFocusNode(int row, int col) {
    final key = _cellKey(row, col);
    if (!_cellFocusNodes.containsKey(key)) {
      final focusNode = FocusNode();
      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          setState(() {
            _focusedRow = row;
            _focusedCol = col;
          });
          widget.onCellFocused?.call(row, col);
        }
      });
      _cellFocusNodes[key] = focusNode;
    }
    return _cellFocusNodes[key]!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = widget.node.style;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table with horizontal scroll support
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                border: style.showBorders
                    ? Border.all(color: Color(style.borderColor), width: 1)
                    : null,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Table(
                defaultColumnWidth: const IntrinsicColumnWidth(flex: 1),
                border: style.showBorders
                    ? TableBorder.all(
                        color: Color(style.borderColor),
                        width: 1,
                      )
                    : null,
                children: [
                  for (int row = 0; row < widget.node.rowCount; row++)
                    TableRow(
                      decoration: BoxDecoration(
                        color: row == 0 &&
                                widget.node.hasHeader &&
                                style.headerBackgroundColor != null
                            ? Color(style.headerBackgroundColor!)
                            : null,
                      ),
                      children: [
                        for (int col = 0; col < widget.node.columnCount; col++)
                          _buildCell(row, col, theme, style),
                      ],
                    ),
                ],
              ),
            ),
          ),
          // Table controls (visible when a cell is focused)
          if (!widget.readOnly && _focusedRow != null) _buildTableControls(theme),
        ],
      ),
    );
  }

  Widget _buildCell(int row, int col, ThemeData theme, TableStyle style) {
    final cell = widget.node.getCell(row, col);
    final isHeader = row == 0 && widget.node.hasHeader;
    final isFocused = _focusedRow == row && _focusedCol == col;

    return Container(
      constraints: const BoxConstraints(minWidth: 80, minHeight: 40),
      padding: EdgeInsets.all(style.cellPadding),
      decoration: BoxDecoration(
        color: isFocused
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : cell.backgroundColor != null
                ? Color(cell.backgroundColor!)
                : null,
      ),
      child: TextField(
        controller: _getController(row, col),
        focusNode: _getFocusNode(row, col),
        readOnly: widget.readOnly,
        maxLines: null,
        textAlign: _getTextAlign(cell.alignment),
        style: isHeader
            ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
            : theme.textTheme.bodyMedium,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        onChanged: (text) {
          widget.onCellChanged?.call(row, col, text);
        },
        onSubmitted: (_) {
          // Move to next cell
          _moveToNextCell(row, col);
        },
      ),
    );
  }

  TextAlign _getTextAlign(TextAlign alignment) {
    switch (alignment) {
      case TextAlign.center:
        return TextAlign.center;
      case TextAlign.right:
        return TextAlign.right;
      case TextAlign.justify:
        return TextAlign.justify;
      case TextAlign.left:
      default:
        return TextAlign.left;
    }
  }

  void _moveToNextCell(int row, int col) {
    int nextCol = col + 1;
    int nextRow = row;

    if (nextCol >= widget.node.columnCount) {
      nextCol = 0;
      nextRow++;
    }

    if (nextRow < widget.node.rowCount) {
      _getFocusNode(nextRow, nextCol).requestFocus();
    }
  }

  Widget _buildTableControls(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildControlButton(
            icon: Icons.add,
            label: 'Row Above',
            onPressed: () => widget.onAddRow?.call(true),
          ),
          _buildControlButton(
            icon: Icons.add,
            label: 'Row Below',
            onPressed: () => widget.onAddRow?.call(false),
          ),
          _buildControlButton(
            icon: Icons.add,
            label: 'Column Left',
            onPressed: () => widget.onAddColumn?.call(true),
          ),
          _buildControlButton(
            icon: Icons.add,
            label: 'Column Right',
            onPressed: () => widget.onAddColumn?.call(false),
          ),
          if (widget.node.rowCount > 1)
            _buildControlButton(
              icon: Icons.remove,
              label: 'Delete Row',
              onPressed: widget.onDeleteRow,
              isDestructive: true,
            ),
          if (widget.node.columnCount > 1)
            _buildControlButton(
              icon: Icons.remove,
              label: 'Delete Column',
              onPressed: widget.onDeleteColumn,
              isDestructive: true,
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isDestructive = false,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isDestructive ? Colors.red : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
