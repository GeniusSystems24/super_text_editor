import 'package:flutter/material.dart';

/// Dialog result for link insertion
class LinkDialogResult {
  /// The URL
  final String url;

  /// The display text
  final String text;

  /// Whether to open in new tab
  final bool openInNewTab;

  /// Creates a new LinkDialogResult
  const LinkDialogResult({
    required this.url,
    required this.text,
    this.openInNewTab = true,
  });
}

/// Dialog for inserting a link
class LinkDialog extends StatefulWidget {
  /// Initial URL
  final String? initialUrl;

  /// Initial text
  final String? initialText;

  /// Creates a new LinkDialog
  const LinkDialog({
    super.key,
    this.initialUrl,
    this.initialText,
  });

  /// Shows the dialog and returns the result
  static Future<LinkDialogResult?> show(
    BuildContext context, {
    String? initialUrl,
    String? initialText,
  }) {
    return showDialog<LinkDialogResult>(
      context: context,
      builder: (context) => LinkDialog(
        initialUrl: initialUrl,
        initialText: initialText,
      ),
    );
  }

  @override
  State<LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<LinkDialog> {
  late final TextEditingController _urlController;
  late final TextEditingController _textController;
  bool _openInNewTab = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialUrl ?? '');
    _textController = TextEditingController(text: widget.initialText ?? '');
  }

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
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://example.com',
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a URL';
                }
                if (!Uri.tryParse(value)!.hasScheme ?? true) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Display Text (optional)',
                hintText: 'Link text',
                prefixIcon: Icon(Icons.text_fields),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Open in new tab'),
              value: _openInNewTab,
              onChanged: (value) {
                setState(() {
                  _openInNewTab = value ?? true;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(LinkDialogResult(
        url: _urlController.text,
        text: _textController.text.isEmpty
            ? _urlController.text
            : _textController.text,
        openInNewTab: _openInNewTab,
      ));
    }
  }
}
