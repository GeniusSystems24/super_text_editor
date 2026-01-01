// import 'package:club_app/utils/project_widget/all_form_widget/html_editor/web_view_widget.dart';
import 'package:control_management_systems/main_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
// import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:recase/recase.dart';

import '../../auto_direction_text.dart';
import 'controllers/editor_controller.dart';
// import 'package:logger/logger.dart';

import 'global_html_view_widget.dart';
import 'widgets/editor_widget.dart';

class HtmlEditorInputFormWidget extends StatefulWidget {
  final String? initialValue;
  final String keyName;
  final String? labelText;
  final String? customPath;
  final bool isRequired;
  final double? height;
  final dynamic revealController;

  const HtmlEditorInputFormWidget({
    super.key,
    this.initialValue,
    required this.keyName,
    this.isRequired = true,
    required this.revealController,
    this.labelText,
    this.height,
    this.customPath,
  });

  @override
  State<HtmlEditorInputFormWidget> createState() =>
      _HtmlEditorInputFormWidgetState();
}

class _HtmlEditorInputFormWidgetState extends State<HtmlEditorInputFormWidget> {
  String? _currentContent;
  late EditorController? controller;

  @override
  void initState() {
    super.initState();
    // Initialize the current content with the initial value
    _currentContent = widget.initialValue ?? '';
    controller = EditorController(
      initialValue: widget.initialValue,
      customPath: widget.customPath,
      showMessage: (String message, {bool isError = false}) {},
      onReady: () => {},
      onContentChanged: (String content) {
        setState(() {
          _currentContent = content;
          final formField = FormBuilder.of(context)?.fields[widget.keyName];
          if (formField != null) {
            formField.didChange(_currentContent);
          }
        });
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // Open the editor in a full-screen dedicated page
  Future<void> _openEditorScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditorScreen(
          controller: controller!,
          labelText: widget.labelText ?? '',
        ),
      ),
    );
    Logger().i("Editor result: $result");
    if (result != null && result != '' && result is String) {
      setState(() {
        _currentContent = result;
      });

      // Notify form field of the change
      final formField = FormBuilder.of(context)?.fields[widget.keyName];
      if (formField != null) {
        formField.didChange(_currentContent);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.labelText != null) ...[
              AutoDirectionText(
                widget.labelText!,
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            FormBuilderField(
              name: widget.keyName,
              validator: FormBuilderValidators.compose([
                if (widget.isRequired)
                  FormBuilderValidators.required(
                    errorText: context.tr.pleaseAddContent.sentenceCase,
                  ),
              ]),
              initialValue: _currentContent,
              builder: (FormFieldState<String> field) {
                return InputDecorator(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(
                      top: 0.0,
                      bottom: 0.0,
                    ),
                    border: InputBorder.none,
                    errorText: field.errorText,
                  ),
                  child: InkWell(
                    onTap: () => _openEditorScreen(),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.5),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      height: widget.height ?? 150,
                      child: _currentContent != null && _currentContent != ''
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Stack(
                                children: [
                                  SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: GlobalHtmlViewWidget(
                                        data: _currentContent,
                                      ),
                                    ),
                                  ),
                                  Positioned.directional(
                                    top: 8,
                                    textDirection: Directionality.of(context),
                                    end: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(6.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: AutoDirectionText(
                                context.tr.clickHereToAddContent.sentenceCase,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
