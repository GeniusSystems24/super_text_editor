import 'iframe_controller.dart';

// Renderer-specific controller
class RendererController extends IframeController {
  RendererController({
    required super.showMessage,
    required super.initialValue,
    required super.onReady,
    super.onHeightChanged, // Add height callback
  }) : super(type: 'renderer');

  @override
  void setupAdditionalHandlers() {
    // Renderer doesn't have additional handlers currently
    // But this method is required by the abstract base class
  }

  @override
  void onIframeReady() {
    // Send app settings immediately when renderer is ready
    sendAppSettings();
    if (initialValue != null) {
      setHtmlContent(initialValue!);
    }
  }

  // Set HTML content in renderer
  Future<void> setHtmlContent(String html) async {
    if (!isReady) {
      // showMessage('Renderer not ready yet', isError: true);
      return;
    }
    await sendCommand('setHtmlContent', {'html': html});
    // showMessage('HTML content sent to renderer');

    // Request height update after content is set
    await Future.delayed(const Duration(milliseconds: 100));
    await requestHeightUpdate();
  }

  // Request height update after content changes
  Future<void> updateHeight() async {
    if (isReady) {
      await requestHeightUpdate();
    }
  }
}
