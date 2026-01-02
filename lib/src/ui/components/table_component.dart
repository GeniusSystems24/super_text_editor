import 'package:flutter/material.dart';
import '../../core/document/nodes.dart';

/// Component for rendering a table node (CKEditor 5 style)
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
  bool _showToolbar = false;
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
            _showToolbar = true;
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Table with horizontal scroll support
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildTable(theme),
          ),
          // Floating toolbar (CKEditor style)
          if (!widget.readOnly && _showToolbar) _buildFloatingToolbar(theme),
        ],
      ),
    );
  }

  Widget _buildTable(ThemeData theme) {
    const borderColor = Color(0xFFBDBDBD);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int row = 0; row < widget.node.rowCount; row++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int col = 0; col < widget.node.columnCount; col++)
                  _buildCell(row, col, theme, borderColor),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCell(int row, int col, ThemeData theme, Color borderColor) {
    final cell = widget.node.getCell(row, col);
    final isHeader = row == 0 && widget.node.hasHeader;
    final isFocused = _focusedRow == row && _focusedCol == col;

    // Determine borders (avoid double borders)
    final isLastCol = col == widget.node.columnCount - 1;
    final isLastRow = row == widget.node.rowCount - 1;

    return Container(
      constraints: const BoxConstraints(minWidth: 100, minHeight: 44),
      decoration: BoxDecoration(
        color: isFocused
            ? const Color(0xFFE3F2FD) // Light blue for selected cell
            : isHeader
                ? const Color(0xFFF5F5F5) // Light gray for header
                : Colors.white,
        border: Border(
          right: isLastCol ? BorderSide.none : BorderSide(color: borderColor, width: 1),
          bottom: isLastRow ? BorderSide.none : BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: TextField(
        controller: _getController(row, col),
        focusNode: _getFocusNode(row, col),
        readOnly: widget.readOnly,
        maxLines: null,
        textAlign: _getTextAlign(cell.alignment),
        style: TextStyle(
          fontSize: 14,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: Colors.black87,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
        onChanged: (text) {
          widget.onCellChanged?.call(row, col, text);
        },
        onSubmitted: (_) {
          _moveToNextCell(row, col);
        },
        onTap: () {
          setState(() {
            _focusedRow = row;
            _focusedCol = col;
            _showToolbar = true;
          });
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

  Widget _buildFloatingToolbar(ThemeData theme) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row operations
            _buildToolbarDropdown(
              icon: Icons.table_rows_outlined,
              tooltip: 'Row',
              items: [
                _DropdownItem('Insert row above', Icons.arrow_upward, () => widget.onAddRow?.call(true)),
                _DropdownItem('Insert row below', Icons.arrow_downward, () => widget.onAddRow?.call(false)),
                if (widget.node.rowCount > 1)
                  _DropdownItem('Delete row', Icons.delete_outline, widget.onDeleteRow, isDestructive: true),
              ],
            ),
            _buildDivider(),
            // Column operations
            _buildToolbarDropdown(
              icon: Icons.view_column_outlined,
              tooltip: 'Column',
              items: [
                _DropdownItem('Insert column left', Icons.arrow_back, () => widget.onAddColumn?.call(true)),
                _DropdownItem('Insert column right', Icons.arrow_forward, () => widget.onAddColumn?.call(false)),
                if (widget.node.columnCount > 1)
                  _DropdownItem('Delete column', Icons.delete_outline, widget.onDeleteColumn, isDestructive: true),
              ],
            ),
            _buildDivider(),
            // Merge cells (placeholder)
            _buildToolbarButton(
              icon: Icons.call_merge,
              tooltip: 'Merge cells',
              onPressed: () {
                // TODO: Implement merge cells
              },
            ),
            _buildDivider(),
            // Table properties
            _buildToolbarDropdown(
              icon: Icons.settings_outlined,
              tooltip: 'Table properties',
              items: [
                _DropdownItem('Toggle header row', Icons.title, () {
                  // Toggle header
                  setState(() {
                    widget.node.hasHeader = !widget.node.hasHeader;
                  });
                }),
                _DropdownItem('Delete table', Icons.delete_forever, () {
                  // Delete table - would need to implement
                }, isDestructive: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarDropdown({
    required IconData icon,
    required String tooltip,
    required List<_DropdownItem> items,
  }) {
    return PopupMenuButton<int>(
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.black54),
          const Icon(Icons.arrow_drop_down, size: 16, color: Colors.black54),
        ],
      ),
      itemBuilder: (context) => items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return PopupMenuItem<int>(
          value: index,
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 18,
                color: item.isDestructive ? Colors.red : Colors.black54,
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  color: item.isDestructive ? Colors.red : Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onSelected: (index) {
        items[index].onTap?.call();
      },
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: const Color(0xFFE0E0E0),
    );
  }
}

class _DropdownItem {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;

  _DropdownItem(this.label, this.icon, this.onTap, {this.isDestructive = false});
}
