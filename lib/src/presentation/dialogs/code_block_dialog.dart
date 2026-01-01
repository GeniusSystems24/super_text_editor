import 'package:flutter/material.dart';

/// Common programming languages for code blocks
const List<String> commonLanguages = [
  'plaintext',
  'dart',
  'javascript',
  'typescript',
  'python',
  'java',
  'kotlin',
  'swift',
  'c',
  'cpp',
  'csharp',
  'go',
  'rust',
  'ruby',
  'php',
  'html',
  'css',
  'scss',
  'sql',
  'json',
  'yaml',
  'xml',
  'markdown',
  'bash',
  'shell',
  'powershell',
];

/// Dialog result for code block insertion
class CodeBlockDialogResult {
  /// The code content
  final String code;

  /// The programming language
  final String language;

  /// Creates a new CodeBlockDialogResult
  const CodeBlockDialogResult({
    required this.code,
    required this.language,
  });
}

/// Dialog for inserting a code block
class CodeBlockDialog extends StatefulWidget {
  /// Initial code
  final String? initialCode;

  /// Initial language
  final String? initialLanguage;

  /// Creates a new CodeBlockDialog
  const CodeBlockDialog({
    super.key,
    this.initialCode,
    this.initialLanguage,
  });

  /// Shows the dialog and returns the result
  static Future<CodeBlockDialogResult?> show(
    BuildContext context, {
    String? initialCode,
    String? initialLanguage,
  }) {
    return showDialog<CodeBlockDialogResult>(
      context: context,
      builder: (context) => CodeBlockDialog(
        initialCode: initialCode,
        initialLanguage: initialLanguage,
      ),
    );
  }

  @override
  State<CodeBlockDialog> createState() => _CodeBlockDialogState();
}

class _CodeBlockDialogState extends State<CodeBlockDialog> {
  late final TextEditingController _codeController;
  late String _selectedLanguage;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.initialCode ?? '');
    _selectedLanguage = widget.initialLanguage ?? 'plaintext';
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Insert Code Block'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language selector
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: const InputDecoration(
                  labelText: 'Language',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                ),
                items: commonLanguages.map((lang) {
                  return DropdownMenuItem(
                    value: lang,
                    child: Text(_formatLanguageName(lang)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value ?? 'plaintext';
                  });
                },
              ),
              const SizedBox(height: 16),
              // Code input
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: TextFormField(
                  controller: _codeController,
                  maxLines: null,
                  expands: true,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Paste or type your code here...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some code';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Insert'),
        ),
      ],
    );
  }

  String _formatLanguageName(String lang) {
    switch (lang) {
      case 'plaintext':
        return 'Plain Text';
      case 'javascript':
        return 'JavaScript';
      case 'typescript':
        return 'TypeScript';
      case 'cpp':
        return 'C++';
      case 'csharp':
        return 'C#';
      case 'scss':
        return 'SCSS';
      case 'sql':
        return 'SQL';
      case 'json':
        return 'JSON';
      case 'yaml':
        return 'YAML';
      case 'xml':
        return 'XML';
      case 'html':
        return 'HTML';
      case 'css':
        return 'CSS';
      case 'php':
        return 'PHP';
      case 'bash':
        return 'Bash';
      default:
        return lang[0].toUpperCase() + lang.substring(1);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(CodeBlockDialogResult(
        code: _codeController.text,
        language: _selectedLanguage,
      ));
    }
  }
}
