import 'package:flutter/material.dart';
import '../../domain/enums/paragraph_type.dart';
import '../../domain/enums/text_alignment.dart';
import '../dialogs/image_dialog.dart';
import '../dialogs/link_dialog.dart';
import '../dialogs/table_dialog.dart';
import '../toolbar/editor_toolbar.dart';
import 'super_editor_controller.dart';

/// A rich text editor widget similar to CKEditor 5
class SuperEditor extends StatefulWidget {
  /// The editor controller
  final SuperEditorController? controller;

  /// Initial HTML content
  final String? initialHtml;

  /// Initial plain text content
  final String? initialText;

  /// Placeholder text when editor is empty
  final String placeholder;

  /// Toolbar configuration
  final EditorToolbarConfig toolbarConfig;

  /// Whether the editor is read-only
  final bool readOnly;

  /// Whether to auto-focus the editor
  final bool autofocus;

  /// Minimum height of the editor
  final double? minHeight;

  /// Maximum height of the editor (null for unlimited)
  final double? maxHeight;

  /// Padding inside the editor
  final EdgeInsets contentPadding;

  /// Callback when content changes
  final ValueChanged<String>? onChanged;

  /// Callback when HTML content changes
  final ValueChanged<String>? onHtmlChanged;

  /// Custom decoration for the editor
  final BoxDecoration? decoration;

  /// Text style for the editor content
  final TextStyle? textStyle;

  /// Whether to show the toolbar
  final bool showToolbar;

  /// Creates a new SuperEditor
  const SuperEditor({
    super.key,
    this.controller,
    this.initialHtml,
    this.initialText,
    this.placeholder = 'Type or paste your content here!',
    this.toolbarConfig = const EditorToolbarConfig(),
    this.readOnly = false,
    this.autofocus = false,
    this.minHeight,
    this.maxHeight,
    this.contentPadding = const EdgeInsets.all(16),
    this.onChanged,
    this.onHtmlChanged,
    this.decoration,
    this.textStyle,
    this.showToolbar = true,
  });

  @override
  State<SuperEditor> createState() => _SuperEditorState();
}

class _SuperEditorState extends State<SuperEditor> {
  late SuperEditorController _controller;
  bool _isInternalController = false;
  bool _showSource = false;
  late TextEditingController _sourceController;

  @override
  void initState() {
    super.initState();
    _initController();
    _sourceController = TextEditingController();
    _controller.addListener(_onControllerChanged);
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isInternalController = false;
    } else {
      _controller = SuperEditorController(
        initialHtml: widget.initialHtml,
        initialText: widget.initialText,
      );
      _isInternalController = true;
    }
  }

  void _onControllerChanged() {
    widget.onChanged?.call(_controller.plainText);
    widget.onHtmlChanged?.call(_controller.html);
  }

  @override
  void didUpdateWidget(SuperEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_isInternalController) {
        _controller.removeListener(_onControllerChanged);
        _controller.dispose();
      }
      _initController();
      _controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_isInternalController) {
      _controller.dispose();
    }
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: widget.decoration ??
          BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Toolbar
            if (widget.showToolbar && !widget.readOnly)
              EditorToolbar(
                controller: _controller,
                config: widget.toolbarConfig,
                onInsertLink: _showLinkDialog,
                onInsertImage: _showImageDialog,
                onInsertTable: _showTableDialog,
                onToggleSource: _toggleSource,
                isSourceView: _showSource,
              ),
            // Editor content
            Expanded(
              child: _showSource ? _buildSourceView() : _buildEditorView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorView() {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Container(
          constraints: BoxConstraints(
            minHeight: widget.minHeight ?? 100,
            maxHeight: widget.maxHeight ?? double.infinity,
          ),
          child: SingleChildScrollView(
            padding: widget.contentPadding,
            child: TextField(
              controller: _controller.textController,
              focusNode: _controller.focusNode,
              readOnly: widget.readOnly,
              autofocus: widget.autofocus,
              maxLines: null,
              minLines: 5,
              textAlign: _getTextAlign(),
              style: _getTextStyle(),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                widget.onChanged?.call(value);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceView() {
    _sourceController.text = _controller.html;

    return Container(
      constraints: BoxConstraints(
        minHeight: widget.minHeight ?? 100,
        maxHeight: widget.maxHeight ?? double.infinity,
      ),
      color: Colors.grey.shade900,
      child: SingleChildScrollView(
        padding: widget.contentPadding,
        child: TextField(
          controller: _sourceController,
          readOnly: widget.readOnly,
          maxLines: null,
          minLines: 10,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: Colors.white,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            _controller.setHtml(value);
          },
        ),
      ),
    );
  }

  TextAlign _getTextAlign() {
    switch (_controller.currentAlignment) {
      case TextAlignment.left:
        return TextAlign.left;
      case TextAlignment.center:
        return TextAlign.center;
      case TextAlignment.right:
        return TextAlign.right;
      case TextAlignment.justify:
        return TextAlign.justify;
    }
  }

  TextStyle _getTextStyle() {
    final baseStyle = widget.textStyle ?? const TextStyle();
    final currentStyle = _controller.currentStyle;

    double fontSize = baseStyle.fontSize ?? 16;
    FontWeight fontWeight = baseStyle.fontWeight ?? FontWeight.normal;

    // Apply paragraph type styles
    switch (_controller.currentParagraphType) {
      case ParagraphType.heading1:
        fontSize = 32;
        fontWeight = FontWeight.bold;
        break;
      case ParagraphType.heading2:
        fontSize = 28;
        fontWeight = FontWeight.bold;
        break;
      case ParagraphType.heading3:
        fontSize = 24;
        fontWeight = FontWeight.bold;
        break;
      case ParagraphType.heading4:
        fontSize = 20;
        fontWeight = FontWeight.bold;
        break;
      case ParagraphType.heading5:
        fontSize = 18;
        fontWeight = FontWeight.bold;
        break;
      case ParagraphType.heading6:
        fontSize = 16;
        fontWeight = FontWeight.bold;
        break;
      default:
        break;
    }

    return baseStyle.copyWith(
      fontSize: fontSize,
      fontWeight: currentStyle.isBold ? FontWeight.bold : fontWeight,
      fontStyle: currentStyle.isItalic ? FontStyle.italic : null,
      decoration: _getTextDecoration(),
      color: currentStyle.textColor,
      backgroundColor: currentStyle.backgroundColor,
      fontFamily: _controller.currentParagraphType == ParagraphType.preformatted
          ? 'monospace'
          : null,
    );
  }

  TextDecoration? _getTextDecoration() {
    final decorations = <TextDecoration>[];
    if (_controller.currentStyle.isUnderline) {
      decorations.add(TextDecoration.underline);
    }
    if (_controller.currentStyle.isStrikethrough) {
      decorations.add(TextDecoration.lineThrough);
    }
    if (decorations.isEmpty) return null;
    return TextDecoration.combine(decorations);
  }

  void _toggleSource() {
    setState(() {
      if (_showSource) {
        // Apply source changes
        _controller.setHtml(_sourceController.text);
      }
      _showSource = !_showSource;
    });
  }

  Future<void> _showLinkDialog() async {
    final selection = _controller.textController.selection;
    String? selectedText;
    if (selection.isValid && !selection.isCollapsed) {
      selectedText = _controller.textController.text
          .substring(selection.start, selection.end);
    }

    final result = await LinkDialog.show(
      context,
      initialText: selectedText,
    );

    if (result != null) {
      _controller.insertLink(result.url, result.text);
    }
  }

  Future<void> _showImageDialog() async {
    final result = await ImageDialog.show(context);

    if (result != null) {
      _controller.insertImage(result.url, alt: result.alt);
    }
  }

  Future<void> _showTableDialog() async {
    final result = await TableDialog.show(context);

    if (result != null) {
      _controller.insertTable(result.rows, result.columns);
    }
  }
}

/// A full-screen editor page
class SuperEditorPage extends StatefulWidget {
  /// The editor controller
  final SuperEditorController? controller;

  /// Initial HTML content
  final String? initialHtml;

  /// Initial plain text content
  final String? initialText;

  /// Page title
  final String title;

  /// Callback when saved
  final ValueChanged<String>? onSave;

  /// Creates a new SuperEditorPage
  const SuperEditorPage({
    super.key,
    this.controller,
    this.initialHtml,
    this.initialText,
    this.title = 'Editor',
    this.onSave,
  });

  /// Shows the editor page and returns the edited HTML
  static Future<String?> show(
    BuildContext context, {
    String? initialHtml,
    String? initialText,
    String title = 'Editor',
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => SuperEditorPage(
          initialHtml: initialHtml,
          initialText: initialText,
          title: title,
        ),
      ),
    );
  }

  @override
  State<SuperEditorPage> createState() => _SuperEditorPageState();
}

class _SuperEditorPageState extends State<SuperEditorPage> {
  late SuperEditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        SuperEditorController(
          initialHtml: widget.initialHtml,
          initialText: widget.initialText,
        );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),
      body: SuperEditor(
        controller: _controller,
        autofocus: true,
      ),
    );
  }

  void _save() {
    final html = _controller.html;
    widget.onSave?.call(html);
    Navigator.of(context).pop(html);
  }
}

/// A form field that integrates with Flutter's Form system
class SuperEditorFormField extends FormField<String> {
  /// Creates a new SuperEditorFormField
  SuperEditorFormField({
    super.key,
    String? initialValue,
    String? initialHtml,
    String? labelText,
    bool readOnly = false,
    bool showToolbar = true,
    double minHeight = 200,
    double? maxHeight,
    EditorToolbarConfig toolbarConfig = const EditorToolbarConfig(),
    super.onSaved,
    super.validator,
    super.autovalidateMode,
  }) : super(
          initialValue: initialValue ?? '',
          builder: (FormFieldState<String> field) {
            final state = field as _SuperEditorFormFieldState;
            final theme = Theme.of(state.context);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (labelText != null) ...[
                  Text(
                    labelText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  height: maxHeight ?? minHeight + 56,
                  child: SuperEditor(
                    controller: state._controller,
                    initialHtml: initialHtml,
                    initialText: initialValue,
                    readOnly: readOnly,
                    showToolbar: showToolbar,
                    toolbarConfig: toolbarConfig,
                    minHeight: minHeight,
                    maxHeight: maxHeight,
                    onChanged: (value) {
                      field.didChange(value);
                    },
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: field.hasError
                            ? theme.colorScheme.error
                            : theme.dividerColor,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (field.hasError) ...[
                  const SizedBox(height: 4),
                  Text(
                    field.errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            );
          },
        );

  @override
  FormFieldState<String> createState() => _SuperEditorFormFieldState();
}

class _SuperEditorFormFieldState extends FormFieldState<String> {
  late SuperEditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SuperEditorController(initialText: widget.initialValue);
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    setValue(_controller.plainText);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  void reset() {
    super.reset();
    _controller.setText(widget.initialValue ?? '');
  }
}
