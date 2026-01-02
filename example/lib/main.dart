import 'package:flutter/material.dart';
import 'package:super_text_editor/super_text_editor.dart';

void main() {
  runApp(const SuperEditorExampleApp());
}

/// Main example application for Super Text Editor v1.0.0
class SuperEditorExampleApp extends StatelessWidget {
  const SuperEditorExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Text Editor v1.0.0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

/// Home page with example tabs
class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Super Text Editor v1.0.0'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Document Editor', icon: Icon(Icons.edit_document)),
            Tab(text: 'Table Demo', icon: Icon(Icons.table_chart)),
            Tab(text: 'Export Demo', icon: Icon(Icons.code)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DocumentEditorExample(),
          TableEditorExample(),
          ExportExample(),
        ],
      ),
    );
  }
}

/// Document Editor Example - showcases the new Document/Node architecture
class DocumentEditorExample extends StatefulWidget {
  const DocumentEditorExample({super.key});

  @override
  State<DocumentEditorExample> createState() => _DocumentEditorExampleState();
}

class _DocumentEditorExampleState extends State<DocumentEditorExample> {
  late DocumentEditorController _controller;

  @override
  void initState() {
    super.initState();
    // Create a document with initial content
    final document = Document([
      ParagraphNode(
        text: AttributedText.fromText('Welcome to Super Text Editor v1.0.0'),
        blockType: BlockType.heading1,
      ),
      ParagraphNode(
        text: AttributedText.fromText(
          'This is a native Flutter document editor built on a Document/Node architecture.',
        ),
      ),
      ParagraphNode(
        text: AttributedText.fromText('Key Features'),
        blockType: BlockType.heading2,
      ),
      ListItemNode.fromText('Document-based architecture (Document = List of Nodes)'),
      ListItemNode.fromText('Rich text formatting with AttributedText'),
      ListItemNode.fromText('Tables with add/remove rows and columns'),
      ListItemNode.fromText('Undo/Redo support'),
      ListItemNode.fromText('HTML and JSON export/import'),
      ParagraphNode(
        text: AttributedText.fromText('Try editing this document!'),
        blockType: BlockType.blockquote,
      ),
    ]);
    _controller = DocumentEditorController(document: document);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        EditorToolbar(
          controller: _controller,
          onInsertLink: _showLinkDialog,
          onInsertImage: _showImageDialog,
        ),
        // Editor
        Expanded(
          child: DocumentEditor(
            controller: _controller,
            placeholder: 'Start typing...',
            padding: const EdgeInsets.all(16),
          ),
        ),
        // Status bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return Text(
                    'Nodes: ${_controller.document.length} | '
                    'Can Undo: ${_controller.canUndo} | '
                    'Can Redo: ${_controller.canRedo}',
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLinkDialog() {
    showDialog(
      context: context,
      builder: (context) => _LinkDialog(
        onInsert: (url, text) {
          _controller.insertLink(url, text);
        },
      ),
    );
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) => _ImageDialog(
        onInsert: (url, alt) {
          _controller.insertImage(url, alt: alt);
        },
      ),
    );
  }
}

/// Table Editor Example - showcases table functionality
class TableEditorExample extends StatefulWidget {
  const TableEditorExample({super.key});

  @override
  State<TableEditorExample> createState() => _TableEditorExampleState();
}

class _TableEditorExampleState extends State<TableEditorExample> {
  late DocumentEditorController _controller;

  @override
  void initState() {
    super.initState();
    // Create a document with a sample table
    final document = Document([
      ParagraphNode(
        text: AttributedText.fromText('Table Editing Demo'),
        blockType: BlockType.heading1,
      ),
      ParagraphNode(
        text: AttributedText.fromText(
          'Click on a table cell to edit it. Use the controls below the table to add or remove rows and columns.',
        ),
      ),
      _createSampleTable(),
      ParagraphNode(
        text: AttributedText.fromText('Try inserting a new table using the Table Size Picker below.'),
      ),
    ]);
    _controller = DocumentEditorController(document: document);
  }

  TableNode _createSampleTable() {
    return TableNode(
      cells: [
        [
          TableCell.fromText('Feature'),
          TableCell.fromText('Status'),
          TableCell.fromText('Notes'),
        ],
        [
          TableCell.fromText('Rich Text'),
          TableCell.fromText('✓'),
          TableCell.fromText('Bold, Italic, Underline, etc.'),
        ],
        [
          TableCell.fromText('Tables'),
          TableCell.fromText('✓'),
          TableCell.fromText('With row/column operations'),
        ],
        [
          TableCell.fromText('Lists'),
          TableCell.fromText('✓'),
          TableCell.fromText('Bullet and numbered'),
        ],
      ],
      hasHeader: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        EditorToolbar(
          controller: _controller,
        ),
        // Editor
        Expanded(
          child: DocumentEditor(
            controller: _controller,
            padding: const EdgeInsets.all(16),
          ),
        ),
        // Table Size Picker
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Insert New Table:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TableSizePicker(
                maxRows: 6,
                maxColumns: 6,
                onSizeSelected: (result) {
                  _controller.insertTable(result.rows, result.columns);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Export Example - showcases HTML and JSON export
class ExportExample extends StatefulWidget {
  const ExportExample({super.key});

  @override
  State<ExportExample> createState() => _ExportExampleState();
}

class _ExportExampleState extends State<ExportExample> {
  late DocumentEditorController _controller;
  String _htmlOutput = '';
  String _jsonOutput = '';
  bool _showHtml = true;

  @override
  void initState() {
    super.initState();
    final document = Document([
      ParagraphNode(
        text: AttributedText.fromText('Export Demo'),
        blockType: BlockType.heading1,
      ),
      ParagraphNode(
        text: AttributedText.fromText(
          'Edit this document and see the HTML/JSON output below.',
        ),
      ),
      ListItemNode.fromText('First item', listType: ListType.numbered),
      ListItemNode.fromText('Second item', listType: ListType.numbered),
      ListItemNode.fromText('Third item', listType: ListType.numbered),
    ]);
    _controller = DocumentEditorController(document: document);
    _controller.addListener(_updateOutput);
    _updateOutput();
  }

  void _updateOutput() {
    setState(() {
      final exporter = HtmlExporter();
      _htmlOutput = exporter.export(_controller.document);

      final serializer = DocumentSerializer();
      _jsonOutput = serializer.serialize(_controller.document, pretty: true);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateOutput);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        EditorToolbar(
          controller: _controller,
        ),
        // Editor (compact)
        SizedBox(
          height: 200,
          child: DocumentEditor(
            controller: _controller,
            padding: const EdgeInsets.all(16),
          ),
        ),
        // Output toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('HTML')),
                  ButtonSegment(value: false, label: Text('JSON')),
                ],
                selected: {_showHtml},
                onSelectionChanged: (value) {
                  setState(() {
                    _showHtml = value.first;
                  });
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy),
                tooltip: 'Copy to clipboard',
                onPressed: () {
                  // Copy to clipboard would go here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard!')),
                  );
                },
              ),
            ],
          ),
        ),
        // Output
        Expanded(
          child: Container(
            color: Colors.grey.shade900,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: SelectableText(
                _showHtml ? _htmlOutput : _jsonOutput,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Link dialog
class _LinkDialog extends StatefulWidget {
  final void Function(String url, String text) onInsert;

  const _LinkDialog({required this.onInsert});

  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  final _urlController = TextEditingController();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Insert Link'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'URL',
              hintText: 'https://example.com',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Link Text',
              hintText: 'Click here',
            ),
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
            widget.onInsert(_urlController.text, _textController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Insert'),
        ),
      ],
    );
  }
}

/// Image dialog
class _ImageDialog extends StatefulWidget {
  final void Function(String url, String alt) onInsert;

  const _ImageDialog({required this.onInsert});

  @override
  State<_ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<_ImageDialog> {
  final _urlController = TextEditingController();
  final _altController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _altController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Insert Image'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Image URL',
              hintText: 'https://example.com/image.png',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _altController,
            decoration: const InputDecoration(
              labelText: 'Alt Text',
              hintText: 'Image description',
            ),
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
            widget.onInsert(_urlController.text, _altController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Insert'),
        ),
      ],
    );
  }
}
