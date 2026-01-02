import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_editor/super_editor.dart';

void main() {
  runApp(const SuperEditorExampleApp());
}

/// Comprehensive Super Editor Example App
/// Showcases all features of the super_editor package
class SuperEditorExampleApp extends StatelessWidget {
  const SuperEditorExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Editor Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const SuperEditorHomePage(),
    );
  }
}

/// Home page with multiple demo tabs
class SuperEditorHomePage extends StatefulWidget {
  const SuperEditorHomePage({super.key});

  @override
  State<SuperEditorHomePage> createState() => _SuperEditorHomePageState();
}

class _SuperEditorHomePageState extends State<SuperEditorHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Editor Demo'),
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Full Editor', icon: Icon(Icons.edit_document)),
            Tab(text: 'Rich Text', icon: Icon(Icons.format_bold)),
            Tab(text: 'Tasks', icon: Icon(Icons.check_box)),
            Tab(text: 'Custom Styles', icon: Icon(Icons.palette)),
            Tab(text: 'Read Only', icon: Icon(Icons.visibility)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FullEditorDemo(),
          RichTextDemo(),
          TasksDemo(),
          CustomStylesDemo(),
          ReadOnlyDemo(),
        ],
      ),
    );
  }
}

// ============================================================================
// Demo 1: Full Featured Editor with Toolbar
// ============================================================================

class FullEditorDemo extends StatefulWidget {
  const FullEditorDemo({super.key});

  @override
  State<FullEditorDemo> createState() => _FullEditorDemoState();
}

class _FullEditorDemoState extends State<FullEditorDemo> {
  late MutableDocument _document;
  late MutableDocumentComposer _composer;
  late Editor _editor;
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _document = _createInitialDocument();
    _composer = MutableDocumentComposer();
    _editor = createDefaultDocumentEditor(
      document: _document,
      composer: _composer,
    );
  }

  MutableDocument _createInitialDocument() {
    return MutableDocument(
      nodes: [
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Welcome to Super Editor'),
          metadata: {'blockType': header1Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            'Super Editor is a powerful, extensible document editor for Flutter. '
            'This demo showcases its key features.',
          ),
        ),
        HorizontalRuleNode(id: Editor.createNodeId()),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Key Features'),
          metadata: {'blockType': header2Attribution},
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText('Rich text formatting (bold, italic, underline, strikethrough)'),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText('Multiple heading levels (H1, H2, H3)'),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText('Bullet and numbered lists'),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText('Task lists with checkboxes'),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText('Images and horizontal rules'),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText('Code blocks and blockquotes'),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Keyboard Shortcuts'),
          metadata: {'blockType': header2Attribution},
        ),
        ListItemNode.ordered(
          id: Editor.createNodeId(),
          text: AttributedText('Cmd/Ctrl + B → Bold'),
        ),
        ListItemNode.ordered(
          id: Editor.createNodeId(),
          text: AttributedText('Cmd/Ctrl + I → Italic'),
        ),
        ListItemNode.ordered(
          id: Editor.createNodeId(),
          text: AttributedText('Cmd/Ctrl + U → Underline'),
        ),
        ListItemNode.ordered(
          id: Editor.createNodeId(),
          text: AttributedText('Cmd/Ctrl + Z → Undo'),
        ),
        ListItemNode.ordered(
          id: Editor.createNodeId(),
          text: AttributedText('Cmd/Ctrl + Shift + Z → Redo'),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            'Try editing this document! Select text to see formatting options.',
          ),
          metadata: {'blockType': blockquoteAttribution},
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom Toolbar
        _buildToolbar(context),
        // Editor
        Expanded(
          child: SuperEditor(
            editor: _editor,
            document: _document,
            composer: _composer,
            focusNode: _focusNode,
            scrollController: _scrollController,
            stylesheet: defaultStylesheet.copyWith(
              addRulesAfter: [
                StyleRule(
                  BlockSelector.all,
                  (doc, docNode) => {
                    Styles.padding: const CascadingPadding.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                  },
                ),
              ],
            ),
            documentOverlayBuilders: [
              DefaultCaretOverlayBuilder(
                caretStyle: const CaretStyle(
                  color: Colors.indigo,
                  width: 2,
                ),
              ),
            ],
          ),
        ),
        // Status Bar
        _buildStatusBar(context),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          // Text style buttons
          _ToolbarButton(
            icon: Icons.format_bold,
            tooltip: 'Bold (Cmd+B)',
            onPressed: () => _toggleAttribution(boldAttribution),
          ),
          _ToolbarButton(
            icon: Icons.format_italic,
            tooltip: 'Italic (Cmd+I)',
            onPressed: () => _toggleAttribution(italicsAttribution),
          ),
          _ToolbarButton(
            icon: Icons.format_underlined,
            tooltip: 'Underline (Cmd+U)',
            onPressed: () => _toggleAttribution(underlineAttribution),
          ),
          _ToolbarButton(
            icon: Icons.format_strikethrough,
            tooltip: 'Strikethrough',
            onPressed: () => _toggleAttribution(strikethroughAttribution),
          ),
          const _ToolbarDivider(),
          // Block type buttons
          _ToolbarButton(
            icon: Icons.title,
            tooltip: 'Heading 1',
            onPressed: () => _setBlockType(header1Attribution),
          ),
          _ToolbarButton(
            icon: Icons.text_fields,
            tooltip: 'Heading 2',
            onPressed: () => _setBlockType(header2Attribution),
          ),
          _ToolbarButton(
            icon: Icons.format_size,
            tooltip: 'Heading 3',
            onPressed: () => _setBlockType(header3Attribution),
          ),
          _ToolbarButton(
            icon: Icons.notes,
            tooltip: 'Paragraph',
            onPressed: () => _setBlockType(null),
          ),
          const _ToolbarDivider(),
          // List buttons
          _ToolbarButton(
            icon: Icons.format_list_bulleted,
            tooltip: 'Bullet List',
            onPressed: _toggleUnorderedList,
          ),
          _ToolbarButton(
            icon: Icons.format_list_numbered,
            tooltip: 'Numbered List',
            onPressed: _toggleOrderedList,
          ),
          _ToolbarButton(
            icon: Icons.check_box,
            tooltip: 'Task List',
            onPressed: _insertTask,
          ),
          const _ToolbarDivider(),
          // Other elements
          _ToolbarButton(
            icon: Icons.format_quote,
            tooltip: 'Blockquote',
            onPressed: () => _setBlockType(blockquoteAttribution),
          ),
          _ToolbarButton(
            icon: Icons.code,
            tooltip: 'Code Block',
            onPressed: _insertCodeBlock,
          ),
          _ToolbarButton(
            icon: Icons.horizontal_rule,
            tooltip: 'Horizontal Rule',
            onPressed: _insertHorizontalRule,
          ),
          _ToolbarButton(
            icon: Icons.image,
            tooltip: 'Insert Image',
            onPressed: () => _showImageDialog(context),
          ),
          const _ToolbarDivider(),
          // Undo/Redo
          _ToolbarButton(
            icon: Icons.undo,
            tooltip: 'Undo (Cmd+Z)',
            onPressed: () => _editor.undo(),
          ),
          _ToolbarButton(
            icon: Icons.redo,
            tooltip: 'Redo (Cmd+Shift+Z)',
            onPressed: () => _editor.redo(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Text(
            'Nodes: ${_document.nodeCount}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
          ListenableBuilder(
            listenable: _composer.selectionNotifier,
            builder: (context, _) {
              final selection = _composer.selection;
              if (selection == null) {
                return Text(
                  'No selection',
                  style: Theme.of(context).textTheme.bodySmall,
                );
              }
              return Text(
                'Selection: ${selection.isCollapsed ? "Caret" : "Range"}',
                style: Theme.of(context).textTheme.bodySmall,
              );
            },
          ),
          const Spacer(),
          Text(
            'Super Editor v0.3.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  void _toggleAttribution(Attribution attribution) {
    final selection = _composer.selection;
    if (selection == null) return;

    _editor.execute([
      ToggleTextAttributionsRequest(
        documentRange: selection,
        attributions: {attribution},
      ),
    ]);
  }

  void _setBlockType(Attribution? blockType) {
    final selection = _composer.selection;
    if (selection == null) return;

    final node = _document.getNodeById(selection.extent.nodeId);
    if (node is! ParagraphNode) return;

    _editor.execute([
      ChangeParagraphBlockTypeRequest(
        nodeId: node.id,
        blockType: blockType,
      ),
    ]);
  }

  void _toggleUnorderedList() {
    final selection = _composer.selection;
    if (selection == null) return;

    final node = _document.getNodeById(selection.extent.nodeId);
    if (node is ListItemNode) {
      // Convert back to paragraph
      _editor.execute([
        ConvertListItemToParagraphRequest(nodeId: node.id),
      ]);
    } else if (node is ParagraphNode) {
      // Convert to list
      _editor.execute([
        ConvertParagraphToListItemRequest(
          nodeId: node.id,
          type: ListItemType.unordered,
        ),
      ]);
    }
  }

  void _toggleOrderedList() {
    final selection = _composer.selection;
    if (selection == null) return;

    final node = _document.getNodeById(selection.extent.nodeId);
    if (node is ListItemNode) {
      _editor.execute([
        ConvertListItemToParagraphRequest(nodeId: node.id),
      ]);
    } else if (node is ParagraphNode) {
      _editor.execute([
        ConvertParagraphToListItemRequest(
          nodeId: node.id,
          type: ListItemType.ordered,
        ),
      ]);
    }
  }

  void _insertTask() {
    final selection = _composer.selection;
    if (selection == null) return;

    final node = _document.getNodeById(selection.extent.nodeId);
    if (node == null) return;

    final nodeIndex = _document.getNodeIndexById(node.id);

    _editor.execute([
      InsertNodeAtIndexRequest(
        nodeIndex: nodeIndex + 1,
        node: TaskNode(
          id: Editor.createNodeId(),
          text: AttributedText('New task'),
          isComplete: false,
        ),
      ),
    ]);
  }

  void _insertCodeBlock() {
    final selection = _composer.selection;
    if (selection == null) return;

    final node = _document.getNodeById(selection.extent.nodeId);
    if (node is! ParagraphNode) return;

    // Set code block style using metadata
    _editor.execute([
      ChangeParagraphBlockTypeRequest(
        nodeId: node.id,
        blockType: codeAttribution,
      ),
    ]);
  }

  void _insertHorizontalRule() {
    final selection = _composer.selection;
    if (selection == null) return;

    final node = _document.getNodeById(selection.extent.nodeId);
    if (node == null) return;

    final nodeIndex = _document.getNodeIndexById(node.id);

    _editor.execute([
      InsertNodeAtIndexRequest(
        nodeIndex: nodeIndex + 1,
        node: HorizontalRuleNode(id: Editor.createNodeId()),
      ),
    ]);
  }

  void _showImageDialog(BuildContext context) {
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert Image'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            labelText: 'Image URL',
            hintText: 'https://example.com/image.png',
            prefixIcon: Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                _insertImage(urlController.text);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Insert'),
          ),
        ],
      ),
    );
  }

  void _insertImage(String url) {
    final selection = _composer.selection;
    if (selection == null) return;

    final node = _document.getNodeById(selection.extent.nodeId);
    if (node == null) return;

    final nodeIndex = _document.getNodeIndexById(node.id);

    _editor.execute([
      InsertNodeAtIndexRequest(
        nodeIndex: nodeIndex + 1,
        node: ImageNode(
          id: Editor.createNodeId(),
          imageUrl: url,
          altText: 'Image',
        ),
      ),
    ]);
  }
}

// ============================================================================
// Demo 2: Rich Text Formatting
// ============================================================================

class RichTextDemo extends StatefulWidget {
  const RichTextDemo({super.key});

  @override
  State<RichTextDemo> createState() => _RichTextDemoState();
}

class _RichTextDemoState extends State<RichTextDemo> {
  late MutableDocument _document;
  late MutableDocumentComposer _composer;
  late Editor _editor;

  @override
  void initState() {
    super.initState();
    _document = _createRichTextDocument();
    _composer = MutableDocumentComposer();
    _editor = createDefaultDocumentEditor(
      document: _document,
      composer: _composer,
    );
  }

  MutableDocument _createRichTextDocument() {
    return MutableDocument(
      nodes: [
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Rich Text Formatting'),
          metadata: {'blockType': header1Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            'Select text and use the buttons above to apply formatting. '
            'You can combine multiple styles on the same text.',
          ),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Text Styles'),
          metadata: {'blockType': header2Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: _createFormattedText(),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Combined Styles'),
          metadata: {'blockType': header2Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: _createCombinedStylesText(),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Try It Yourself'),
          metadata: {'blockType': header2Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            'Type here and experiment with different text formatting options...',
          ),
        ),
      ],
    );
  }

  AttributedText _createFormattedText() {
    final text = AttributedText('This is bold, this is italic, this is underlined, and this is strikethrough.');
    // Apply bold to "bold"
    text.addAttribution(boldAttribution, const SpanRange(8, 11));
    // Apply italic to "italic"
    text.addAttribution(italicsAttribution, const SpanRange(23, 28));
    // Apply underline to "underlined"
    text.addAttribution(underlineAttribution, const SpanRange(40, 49));
    // Apply strikethrough to "strikethrough"
    text.addAttribution(strikethroughAttribution, const SpanRange(65, 77));
    return text;
  }

  AttributedText _createCombinedStylesText() {
    final text = AttributedText('You can combine bold and italic, or even bold, italic, and underlined together!');
    // Bold + Italic
    text.addAttribution(boldAttribution, const SpanRange(16, 30));
    text.addAttribution(italicsAttribution, const SpanRange(21, 30));
    // Bold + Italic + Underline
    text.addAttribution(boldAttribution, const SpanRange(41, 69));
    text.addAttribution(italicsAttribution, const SpanRange(48, 69));
    text.addAttribution(underlineAttribution, const SpanRange(60, 69));
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Formatting buttons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FormatButton(
                icon: Icons.format_bold,
                label: 'Bold',
                onPressed: () => _toggleStyle(boldAttribution),
              ),
              const SizedBox(width: 8),
              _FormatButton(
                icon: Icons.format_italic,
                label: 'Italic',
                onPressed: () => _toggleStyle(italicsAttribution),
              ),
              const SizedBox(width: 8),
              _FormatButton(
                icon: Icons.format_underlined,
                label: 'Underline',
                onPressed: () => _toggleStyle(underlineAttribution),
              ),
              const SizedBox(width: 8),
              _FormatButton(
                icon: Icons.format_strikethrough,
                label: 'Strike',
                onPressed: () => _toggleStyle(strikethroughAttribution),
              ),
            ],
          ),
        ),
        // Editor
        Expanded(
          child: SuperEditor(
            editor: _editor,
            document: _document,
            composer: _composer,
            stylesheet: defaultStylesheet.copyWith(
              addRulesAfter: [
                StyleRule(
                  BlockSelector.all,
                  (doc, docNode) => {
                    Styles.padding: const CascadingPadding.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _toggleStyle(Attribution attribution) {
    final selection = _composer.selection;
    if (selection == null) return;

    _editor.execute([
      ToggleTextAttributionsRequest(
        documentRange: selection,
        attributions: {attribution},
      ),
    ]);
  }
}

class _FormatButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _FormatButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }
}

// ============================================================================
// Demo 3: Tasks / Checkboxes
// ============================================================================

class TasksDemo extends StatefulWidget {
  const TasksDemo({super.key});

  @override
  State<TasksDemo> createState() => _TasksDemoState();
}

class _TasksDemoState extends State<TasksDemo> {
  late MutableDocument _document;
  late MutableDocumentComposer _composer;
  late Editor _editor;

  @override
  void initState() {
    super.initState();
    _document = _createTasksDocument();
    _composer = MutableDocumentComposer();
    _editor = createDefaultDocumentEditor(
      document: _document,
      composer: _composer,
    );
  }

  MutableDocument _createTasksDocument() {
    return MutableDocument(
      nodes: [
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Task Management'),
          metadata: {'blockType': header1Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            'Super Editor supports interactive task lists. Click on a checkbox to toggle its state.',
          ),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Project Setup'),
          metadata: {'blockType': header2Attribution},
        ),
        TaskNode(
          id: Editor.createNodeId(),
          text: AttributedText('Install Flutter SDK'),
          isComplete: true,
        ),
        TaskNode(
          id: Editor.createNodeId(),
          text: AttributedText('Create new project'),
          isComplete: true,
        ),
        TaskNode(
          id: Editor.createNodeId(),
          text: AttributedText('Add super_editor dependency'),
          isComplete: true,
        ),
        TaskNode(
          id: Editor.createNodeId(),
          text: AttributedText('Configure project settings'),
          isComplete: false,
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Implementation'),
          metadata: {'blockType': header2Attribution},
        ),
        TaskNode(
          id: Editor.createNodeId(),
          text: AttributedText('Create document model'),
          isComplete: false,
        ),
        TaskNode(
          id: Editor.createNodeId(),
          text: AttributedText('Build editor UI'),
          isComplete: false,
        ),
        TaskNode(
          id: Editor.createNodeId(),
          text: AttributedText('Add formatting toolbar'),
          isComplete: false,
        ),
        TaskNode(
          id: Editor.createNodeId(),
          text: AttributedText('Implement save/load functionality'),
          isComplete: false,
        ),
        TaskNode(
          id: Editor.createNodeId(),
          text: AttributedText('Write tests'),
          isComplete: false,
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Deployment'),
          metadata: {'blockType': header2Attribution},
        ),
        TaskNode(
          id: Editor.createNodeId(),
          text: AttributedText('Build for Android'),
          isComplete: false,
        ),
        TaskNode(
          id: Editor.createNodeId(),
          text: AttributedText('Build for iOS'),
          isComplete: false,
        ),
        TaskNode(
          id: Editor.createNodeId(),
          text: AttributedText('Deploy to stores'),
          isComplete: false,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add task button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            children: [
              FilledButton.icon(
                onPressed: _addNewTask,
                icon: const Icon(Icons.add),
                label: const Text('Add New Task'),
              ),
              const Spacer(),
              ListenableBuilder(
                listenable: _document,
                builder: (context, _) {
                  final tasks = _document.nodes.whereType<TaskNode>();
                  final completed = tasks.where((t) => t.isComplete).length;
                  final total = tasks.length;
                  return Text(
                    'Progress: $completed / $total tasks completed',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                },
              ),
            ],
          ),
        ),
        // Progress bar
        ListenableBuilder(
          listenable: _document,
          builder: (context, _) {
            final tasks = _document.nodes.whereType<TaskNode>();
            final completed = tasks.where((t) => t.isComplete).length;
            final total = tasks.length;
            final progress = total > 0 ? completed / total : 0.0;
            return LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            );
          },
        ),
        // Editor
        Expanded(
          child: SuperEditor(
            editor: _editor,
            document: _document,
            composer: _composer,
            stylesheet: defaultStylesheet.copyWith(
              addRulesAfter: [
                StyleRule(
                  BlockSelector.all,
                  (doc, docNode) => {
                    Styles.padding: const CascadingPadding.symmetric(
                      horizontal: 32,
                      vertical: 8,
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addNewTask() {
    // Find the last task node or insert at the end
    int insertIndex = _document.nodeCount;
    for (int i = _document.nodeCount - 1; i >= 0; i--) {
      if (_document.getNodeAt(i) is TaskNode) {
        insertIndex = i + 1;
        break;
      }
    }

    _editor.execute([
      InsertNodeAtIndexRequest(
        nodeIndex: insertIndex,
        node: TaskNode(
          id: Editor.createNodeId(),
          text: AttributedText('New task'),
          isComplete: false,
        ),
      ),
    ]);
  }
}

// ============================================================================
// Demo 4: Custom Styles
// ============================================================================

class CustomStylesDemo extends StatefulWidget {
  const CustomStylesDemo({super.key});

  @override
  State<CustomStylesDemo> createState() => _CustomStylesDemoState();
}

class _CustomStylesDemoState extends State<CustomStylesDemo> {
  late MutableDocument _document;
  late MutableDocumentComposer _composer;
  late Editor _editor;
  bool _useDarkStyle = false;

  @override
  void initState() {
    super.initState();
    _document = _createStyledDocument();
    _composer = MutableDocumentComposer();
    _editor = createDefaultDocumentEditor(
      document: _document,
      composer: _composer,
    );
  }

  MutableDocument _createStyledDocument() {
    return MutableDocument(
      nodes: [
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Custom Styled Editor'),
          metadata: {'blockType': header1Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            'Super Editor allows extensive customization of document styles. '
            'Toggle the switch above to see different style presets.',
          ),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Style Features'),
          metadata: {'blockType': header2Attribution},
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText('Custom fonts and typography'),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText('Configurable colors and backgrounds'),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText('Adjustable padding and spacing'),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText('Custom block decorations'),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            'This is a blockquote with custom styling applied.',
          ),
          metadata: {'blockType': blockquoteAttribution},
        ),
        HorizontalRuleNode(id: Editor.createNodeId()),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            'The styling system in Super Editor is based on cascading style rules, '
            'similar to CSS. This makes it easy to create consistent document themes.',
          ),
        ),
      ],
    );
  }

  Stylesheet get _lightStylesheet => defaultStylesheet.copyWith(
        addRulesAfter: [
          StyleRule(
            BlockSelector.all,
            (doc, docNode) => {
              Styles.padding: const CascadingPadding.symmetric(
                horizontal: 40,
                vertical: 12,
              ),
            },
          ),
          StyleRule(
            const BlockSelector('header1'),
            (doc, docNode) => {
              Styles.textStyle: const TextStyle(
                color: Colors.indigo,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            },
          ),
          StyleRule(
            const BlockSelector('header2'),
            (doc, docNode) => {
              Styles.textStyle: const TextStyle(
                color: Colors.indigo,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            },
          ),
          StyleRule(
            const BlockSelector('blockquote'),
            (doc, docNode) => {
              Styles.textStyle: const TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            },
          ),
        ],
      );

  Stylesheet get _darkStylesheet => Stylesheet(
        rules: [
          StyleRule(
            BlockSelector.all,
            (doc, docNode) => {
              Styles.padding: const CascadingPadding.symmetric(
                horizontal: 40,
                vertical: 12,
              ),
              Styles.textStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.6,
              ),
            },
          ),
          StyleRule(
            const BlockSelector('header1'),
            (doc, docNode) => {
              Styles.textStyle: const TextStyle(
                color: Colors.amber,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            },
          ),
          StyleRule(
            const BlockSelector('header2'),
            (doc, docNode) => {
              Styles.textStyle: const TextStyle(
                color: Colors.amber,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            },
          ),
          StyleRule(
            const BlockSelector('blockquote'),
            (doc, docNode) => {
              Styles.textStyle: const TextStyle(
                color: Colors.white54,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            },
          ),
          StyleRule(
            const BlockSelector('listItem'),
            (doc, docNode) => {
              Styles.textStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            },
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Style toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Light Style'),
              const SizedBox(width: 12),
              Switch(
                value: _useDarkStyle,
                onChanged: (value) {
                  setState(() {
                    _useDarkStyle = value;
                  });
                },
              ),
              const SizedBox(width: 12),
              const Text('Dark Style'),
            ],
          ),
        ),
        // Editor with custom styles
        Expanded(
          child: Container(
            color: _useDarkStyle ? const Color(0xFF1E1E1E) : Colors.white,
            child: SuperEditor(
              editor: _editor,
              document: _document,
              composer: _composer,
              stylesheet: _useDarkStyle ? _darkStylesheet : _lightStylesheet,
              documentOverlayBuilders: [
                DefaultCaretOverlayBuilder(
                  caretStyle: CaretStyle(
                    color: _useDarkStyle ? Colors.amber : Colors.indigo,
                    width: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Demo 5: Read-Only Document Viewer
// ============================================================================

class ReadOnlyDemo extends StatefulWidget {
  const ReadOnlyDemo({super.key});

  @override
  State<ReadOnlyDemo> createState() => _ReadOnlyDemoState();
}

class _ReadOnlyDemoState extends State<ReadOnlyDemo> {
  late MutableDocument _document;

  @override
  void initState() {
    super.initState();
    _document = _createReadOnlyDocument();
  }

  MutableDocument _createReadOnlyDocument() {
    return MutableDocument(
      nodes: [
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Read-Only Document'),
          metadata: {'blockType': header1Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            'This document is displayed in read-only mode using SuperReader. '
            'Users can view and select text, but cannot edit it.',
          ),
        ),
        HorizontalRuleNode(id: Editor.createNodeId()),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Use Cases'),
          metadata: {'blockType': header2Attribution},
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText('Documentation viewers'),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText('Article readers'),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText('Terms of service displays'),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText('Preview modes in editors'),
        ),
        ListItemNode.unordered(
          id: Editor.createNodeId(),
          text: AttributedText('Export previews'),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText('Features'),
          metadata: {'blockType': header2Attribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            'SuperReader supports all the same document content as SuperEditor, '
            'including rich text, lists, images, tasks, and more. '
            'The only difference is that editing is disabled.',
          ),
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            'Users can still select and copy text, which is useful for sharing content.',
          ),
          metadata: {'blockType': blockquoteAttribution},
        ),
        ParagraphNode(
          id: Editor.createNodeId(),
          text: AttributedText(
            'Try selecting some text in this document - you can copy it, '
            'but you cannot modify it.',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Row(
            children: [
              Icon(
                Icons.info,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This document is in read-only mode. You can select and copy text, but not edit it.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Read-only document viewer
        Expanded(
          child: SuperReader(
            document: _document,
            stylesheet: defaultStylesheet.copyWith(
              addRulesAfter: [
                StyleRule(
                  BlockSelector.all,
                  (doc, docNode) => {
                    Styles.padding: const CascadingPadding.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
        // Footer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              const Icon(Icons.article_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                'Document nodes: ${_document.nodeCount}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // Copy all text to clipboard
                  final buffer = StringBuffer();
                  for (final node in _document.nodes) {
                    if (node is TextNode) {
                      buffer.writeln(node.text.text);
                    }
                  }
                  Clipboard.setData(ClipboardData(text: buffer.toString()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Document copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy All'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// Toolbar Widgets
// ============================================================================

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size(36, 36),
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Theme.of(context).dividerColor,
    );
  }
}
