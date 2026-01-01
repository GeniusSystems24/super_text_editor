import 'package:flutter/material.dart';

/// Dialog result for image insertion
class ImageDialogResult {
  /// The image URL
  final String url;

  /// Alt text
  final String alt;

  /// Width (null for auto)
  final double? width;

  /// Height (null for auto)
  final double? height;

  /// Creates a new ImageDialogResult
  const ImageDialogResult({
    required this.url,
    this.alt = '',
    this.width,
    this.height,
  });
}

/// Dialog for inserting an image
class ImageDialog extends StatefulWidget {
  /// Initial URL
  final String? initialUrl;

  /// Initial alt text
  final String? initialAlt;

  /// Creates a new ImageDialog
  const ImageDialog({
    super.key,
    this.initialUrl,
    this.initialAlt,
  });

  /// Shows the dialog and returns the result
  static Future<ImageDialogResult?> show(
    BuildContext context, {
    String? initialUrl,
    String? initialAlt,
  }) {
    return showDialog<ImageDialogResult>(
      context: context,
      builder: (context) => ImageDialog(
        initialUrl: initialUrl,
        initialAlt: initialAlt,
      ),
    );
  }

  @override
  State<ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
  late final TextEditingController _urlController;
  late final TextEditingController _altController;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  final _formKey = GlobalKey<FormState>();
  String? _previewError;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialUrl ?? '');
    _altController = TextEditingController(text: widget.initialAlt ?? '');
    _widthController = TextEditingController();
    _heightController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _altController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Insert Image'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  hintText: 'https://example.com/image.jpg',
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _altController,
                decoration: const InputDecoration(
                  labelText: 'Alt Text (for accessibility)',
                  hintText: 'Describe the image',
                  prefixIcon: Icon(Icons.accessibility),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _widthController,
                      decoration: const InputDecoration(
                        labelText: 'Width (px)',
                        hintText: 'Auto',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (px)',
                        hintText: 'Auto',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_urlController.text.isNotEmpty) ...[
                const Text(
                  'Preview:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _previewError != null
                      ? Center(
                          child: Text(
                            _previewError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : Image.network(
                          _urlController.text,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                ),
              ],
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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(ImageDialogResult(
        url: _urlController.text,
        alt: _altController.text,
        width: double.tryParse(_widthController.text),
        height: double.tryParse(_heightController.text),
      ));
    }
  }
}
