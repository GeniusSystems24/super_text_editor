import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Result of find operation
class FindResult {
  /// Start index of match
  final int start;

  /// End index of match
  final int end;

  /// The matched text
  final String text;

  const FindResult({
    required this.start,
    required this.end,
    required this.text,
  });
}

/// Controller for find and replace functionality
class FindReplaceController extends ChangeNotifier {
  final TextEditingController textController;

  String _searchQuery = '';
  String _replaceText = '';
  bool _caseSensitive = false;
  bool _wholeWord = false;
  bool _useRegex = false;

  List<FindResult> _results = [];
  int _currentIndex = -1;

  FindReplaceController({required this.textController});

  /// Current search query
  String get searchQuery => _searchQuery;

  /// Current replace text
  String get replaceText => _replaceText;

  /// Whether search is case sensitive
  bool get caseSensitive => _caseSensitive;

  /// Whether to match whole words only
  bool get wholeWord => _wholeWord;

  /// Whether to use regex
  bool get useRegex => _useRegex;

  /// All find results
  List<FindResult> get results => _results;

  /// Current result index
  int get currentIndex => _currentIndex;

  /// Current result count
  int get resultCount => _results.length;

  /// Whether there are any results
  bool get hasResults => _results.isNotEmpty;

  /// Current result (if any)
  FindResult? get currentResult =>
      _currentIndex >= 0 && _currentIndex < _results.length
          ? _results[_currentIndex]
          : null;

  /// Sets the search query and performs search
  void setSearchQuery(String query) {
    _searchQuery = query;
    _performSearch();
  }

  /// Sets the replace text
  void setReplaceText(String text) {
    _replaceText = text;
    notifyListeners();
  }

  /// Toggles case sensitivity
  void toggleCaseSensitive() {
    _caseSensitive = !_caseSensitive;
    _performSearch();
  }

  /// Toggles whole word matching
  void toggleWholeWord() {
    _wholeWord = !_wholeWord;
    _performSearch();
  }

  /// Toggles regex mode
  void toggleRegex() {
    _useRegex = !_useRegex;
    _performSearch();
  }

  void _performSearch() {
    _results = [];
    _currentIndex = -1;

    if (_searchQuery.isEmpty) {
      notifyListeners();
      return;
    }

    final text = textController.text;
    Pattern pattern;

    try {
      if (_useRegex) {
        pattern = RegExp(
          _searchQuery,
          caseSensitive: _caseSensitive,
        );
      } else {
        String escapedQuery = RegExp.escape(_searchQuery);
        if (_wholeWord) {
          escapedQuery = '\\b$escapedQuery\\b';
        }
        pattern = RegExp(
          escapedQuery,
          caseSensitive: _caseSensitive,
        );
      }

      final matches = pattern.allMatches(text);
      for (final match in matches) {
        _results.add(FindResult(
          start: match.start,
          end: match.end,
          text: match.group(0) ?? '',
        ));
      }

      if (_results.isNotEmpty) {
        _currentIndex = 0;
        _selectCurrentResult();
      }
    } catch (e) {
      // Invalid regex
      _results = [];
    }

    notifyListeners();
  }

  /// Moves to next result
  void findNext() {
    if (_results.isEmpty) return;

    _currentIndex = (_currentIndex + 1) % _results.length;
    _selectCurrentResult();
    notifyListeners();
  }

  /// Moves to previous result
  void findPrevious() {
    if (_results.isEmpty) return;

    _currentIndex = (_currentIndex - 1 + _results.length) % _results.length;
    _selectCurrentResult();
    notifyListeners();
  }

  void _selectCurrentResult() {
    final result = currentResult;
    if (result != null) {
      textController.selection = TextSelection(
        baseOffset: result.start,
        extentOffset: result.end,
      );
    }
  }

  /// Replaces current match
  void replaceCurrent() {
    final result = currentResult;
    if (result == null) return;

    final text = textController.text;
    final newText = text.substring(0, result.start) +
        _replaceText +
        text.substring(result.end);

    textController.text = newText;
    textController.selection = TextSelection.collapsed(
      offset: result.start + _replaceText.length,
    );

    _performSearch();
  }

  /// Replaces all matches
  void replaceAll() {
    if (_results.isEmpty) return;

    final text = textController.text;
    String newText = text;

    // Replace from end to start to preserve indices
    for (int i = _results.length - 1; i >= 0; i--) {
      final result = _results[i];
      newText = newText.substring(0, result.start) +
          _replaceText +
          newText.substring(result.end);
    }

    textController.text = newText;
    _performSearch();
  }

  /// Clears the search
  void clear() {
    _searchQuery = '';
    _replaceText = '';
    _results = [];
    _currentIndex = -1;
    notifyListeners();
  }

  @override
  void dispose() {
    clear();
    super.dispose();
  }
}

/// Find and Replace dialog/panel
class FindReplacePanel extends StatefulWidget {
  /// The find/replace controller
  final FindReplaceController controller;

  /// Whether to show replace functionality
  final bool showReplace;

  /// Callback when panel is closed
  final VoidCallback? onClose;

  const FindReplacePanel({
    super.key,
    required this.controller,
    this.showReplace = true,
    this.onClose,
  });

  @override
  State<FindReplacePanel> createState() => _FindReplacePanelState();
}

class _FindReplacePanelState extends State<FindReplacePanel> {
  late final TextEditingController _findController;
  late final TextEditingController _replaceController;
  final FocusNode _findFocusNode = FocusNode();
  bool _showReplace = false;

  @override
  void initState() {
    super.initState();
    _findController = TextEditingController(
      text: widget.controller.searchQuery,
    );
    _replaceController = TextEditingController(
      text: widget.controller.replaceText,
    );
    _showReplace = widget.showReplace;

    // Auto-focus find field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _findController.dispose();
    _replaceController.dispose();
    _findFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Find row
              Row(
                children: [
                  // Toggle replace button
                  IconButton(
                    icon: Icon(
                      _showReplace
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_right,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _showReplace = !_showReplace;
                      });
                    },
                    tooltip: _showReplace ? 'Hide Replace' : 'Show Replace',
                    visualDensity: VisualDensity.compact,
                  ),
                  // Find input
                  Expanded(
                    child: _buildFindField(),
                  ),
                  const SizedBox(width: 8),
                  // Result count
                  if (widget.controller.searchQuery.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.controller.hasResults
                            ? '${widget.controller.currentIndex + 1}/${widget.controller.resultCount}'
                            : 'No results',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(width: 8),
                  // Navigation buttons
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up, size: 20),
                    onPressed: widget.controller.hasResults
                        ? widget.controller.findPrevious
                        : null,
                    tooltip: 'Previous (Shift+Enter)',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                    onPressed: widget.controller.hasResults
                        ? widget.controller.findNext
                        : null,
                    tooltip: 'Next (Enter)',
                    visualDensity: VisualDensity.compact,
                  ),
                  // Options
                  _buildOptionButton(
                    'Aa',
                    'Case Sensitive',
                    widget.controller.caseSensitive,
                    widget.controller.toggleCaseSensitive,
                  ),
                  _buildOptionButton(
                    'W',
                    'Whole Word',
                    widget.controller.wholeWord,
                    widget.controller.toggleWholeWord,
                  ),
                  _buildOptionButton(
                    '.*',
                    'Regular Expression',
                    widget.controller.useRegex,
                    widget.controller.toggleRegex,
                  ),
                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onClose?.call();
                    },
                    tooltip: 'Close (Escape)',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              // Replace row
              if (_showReplace) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(width: 40), // Align with find field
                    // Replace input
                    Expanded(
                      child: _buildReplaceField(),
                    ),
                    const SizedBox(width: 8),
                    // Replace buttons
                    TextButton(
                      onPressed: widget.controller.hasResults
                          ? widget.controller.replaceCurrent
                          : null,
                      child: const Text('Replace'),
                    ),
                    TextButton(
                      onPressed: widget.controller.hasResults
                          ? widget.controller.replaceAll
                          : null,
                      child: const Text('Replace All'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFindField() {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            if (HardwareKeyboard.instance.isShiftPressed) {
              widget.controller.findPrevious();
            } else {
              widget.controller.findNext();
            }
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            widget.controller.clear();
            widget.onClose?.call();
          }
        }
      },
      child: TextField(
        controller: _findController,
        focusNode: _findFocusNode,
        decoration: InputDecoration(
          hintText: 'Find',
          isDense: true,
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        onChanged: widget.controller.setSearchQuery,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => widget.controller.findNext(),
      ),
    );
  }

  Widget _buildReplaceField() {
    return TextField(
      controller: _replaceController,
      decoration: InputDecoration(
        hintText: 'Replace',
        isDense: true,
        prefixIcon: const Icon(Icons.find_replace, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
      ),
      onChanged: widget.controller.setReplaceText,
      onSubmitted: (_) => widget.controller.replaceCurrent(),
    );
  }

  Widget _buildOptionButton(
    String label,
    String tooltip,
    bool isActive,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
