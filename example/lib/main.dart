import 'package:flutter/material.dart';
import 'package:super_text_editor/super_text_editor.dart';

void main() {
  runApp(const SuperEditorExampleApp());
}

/// Main example application
class SuperEditorExampleApp extends StatelessWidget {
  const SuperEditorExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Super Text Editor Example',
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

/// Home page with multiple example tabs
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
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Super Text Editor'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Basic', icon: Icon(Icons.edit)),
            Tab(text: 'Full Featured', icon: Icon(Icons.text_fields)),
            Tab(text: 'Form Field', icon: Icon(Icons.assignment)),
            Tab(text: 'Minimal', icon: Icon(Icons.short_text)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BasicEditorExample(),
          FullFeaturedEditorExample(),
          FormFieldExample(),
          MinimalEditorExample(),
        ],
      ),
    );
  }
}

/// Basic editor example
class BasicEditorExample extends StatefulWidget {
  const BasicEditorExample({super.key});

  @override
  State<BasicEditorExample> createState() => _BasicEditorExampleState();
}

class _BasicEditorExampleState extends State<BasicEditorExample> {
  final _controller = SuperEditorController();
  String _htmlOutput = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Basic Editor',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'A simple editor with basic text formatting options.',
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 2,
            child: SuperEditor(
              controller: _controller,
              placeholder: 'Start typing here...',
              toolbarConfig: EditorToolbarConfig.basic,
              onHtmlChanged: (html) {
                setState(() {
                  _htmlOutput = html;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'HTML Output:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _htmlOutput.isEmpty ? 'HTML will appear here...' : _htmlOutput,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full featured editor example
class FullFeaturedEditorExample extends StatefulWidget {
  const FullFeaturedEditorExample({super.key});

  @override
  State<FullFeaturedEditorExample> createState() =>
      _FullFeaturedEditorExampleState();
}

class _FullFeaturedEditorExampleState extends State<FullFeaturedEditorExample> {
  final _controller = SuperEditorController(
    initialHtml: '''
<h1>Welcome to Super Text Editor</h1>
<p>This is a <strong>powerful</strong> rich text editor for Flutter.</p>
<h2>Features</h2>
<ul>
<li>Bold, italic, underline, strikethrough</li>
<li>Text color and highlight</li>
<li>Multiple heading levels</li>
<li>Ordered and unordered lists</li>
<li>Text alignment</li>
<li>Links and images</li>
<li>Tables</li>
<li>And much more!</li>
</ul>
<p>Try editing this content to see all the features in action.</p>
''',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Full Featured Editor',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'All toolbar features enabled including source view.',
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  _showHtmlDialog(context);
                },
                icon: const Icon(Icons.code),
                label: const Text('View HTML'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SuperEditor(
              controller: _controller,
              toolbarConfig: const EditorToolbarConfig(showSourceCode: true),
              autofocus: true,
            ),
          ),
        ],
      ),
    );
  }

  void _showHtmlDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('HTML Output'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              _controller.html,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Form field example
class FormFieldExample extends StatefulWidget {
  const FormFieldExample({super.key});

  @override
  State<FormFieldExample> createState() => _FormFieldExampleState();
}

class _FormFieldExampleState extends State<FormFieldExample> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _content = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Form Integration',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Editor integrated with Flutter Form for validation.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              onSaved: (value) => _title = value ?? '',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SuperEditorFormField(
                labelText: 'Content',
                minHeight: 200,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some content';
                  }
                  if (value.length < 10) {
                    return 'Content must be at least 10 characters';
                  }
                  return null;
                },
                onSaved: (value) => _content = value ?? '',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _formKey.currentState?.reset();
                  },
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _submitForm,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Form submitted!\nTitle: $_title\nContent length: ${_content.length}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

/// Minimal editor example
class MinimalEditorExample extends StatefulWidget {
  const MinimalEditorExample({super.key});

  @override
  State<MinimalEditorExample> createState() => _MinimalEditorExampleState();
}

class _MinimalEditorExampleState extends State<MinimalEditorExample> {
  final _controller = SuperEditorController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Minimal Editor',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'A minimal editor with only basic formatting (B/I/U/S).',
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SuperEditor(
              controller: _controller,
              placeholder: 'Write something simple...',
              toolbarConfig: EditorToolbarConfig.minimal,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toolbar Configurations:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('• EditorToolbarConfig.full - All features'),
                  const Text('• EditorToolbarConfig.basic - Text formatting only'),
                  const Text('• EditorToolbarConfig.minimal - Bold, Italic, Underline, Strikethrough'),
                  const Text('• Custom - Configure individual features'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
