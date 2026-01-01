import 'iframe_controller.dart';

// Editor-specific controller
class EditorController extends IframeController {
  String _lastContent = '';
  String? customPath;
  final void Function(String content) onContentChanged;

  EditorController({
    required super.showMessage,
    required super.onReady,
    required super.initialValue,
    this.customPath,
    required this.onContentChanged,
  }) : super(type: 'editor');

  String get lastContent => _lastContent;

  @override
  void setupAdditionalHandlers() {
    if (controller == null) return;

    // Handler for content changes from editor
    controller!.addJavaScriptHandler(
      handlerName: 'onContentChanged',
      callback: (args) {
        if (args.isNotEmpty) {
          _lastContent = args[0].toString();
          onContentChanged(_lastContent);
          // showMessage('Content updated from editor');
        }
      },
    );
  }

  @override
  void onIframeReady() {
    // Send app settings and upload path immediately when editor is ready
    sendAppSettings();
    setUploadPath(customPath ?? '');
    if (initialValue != null) {
      loadContent(initialValue!);
    }
  }

  // Load content into editor
  Future<void> loadContent(String content) async {
    if (!isReady) {
      // showMessage('Editor not ready yet', isError: true);
      return;
    }

    await sendCommand('load', {'content': content});
    // showMessage('Content sent to editor');
  }

  // Get current content from editor
  Future<void> getContent() async {
    if (!isReady) {
      // showMessage('Editor not ready yet', isError: true);
      return;
    }

    await sendCommand('getContent', {});
    // showMessage('Requested content from editor');
  }

  // Set upload path for images
  Future<void> setUploadPath(String path) async {
    if (!isReady) {
      // showMessage('Editor not ready yet', isError: true);
      return;
    }

    await sendMessage('setUploadPath', {'path': path});
    // showMessage('Upload path sent to editor');
  }
}
