import 'package:control_management_systems/core/settings/language.dart';
import 'package:control_management_systems/core/settings/theme_mode.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';
import 'dart:async';

abstract class IframeController {
  InAppWebViewController? _controller;
  String? initialValue;

  bool _isReady = false;
  final void Function() _onReady;
  final String _type;
  void Function(double height)? _onHeightChanged; // Add height callback

  // Message debouncing
  final Map<String, DateTime> _recentMessages = {};
  Timer? _cleanupTimer;
  static const Duration _debounceDuration = Duration(seconds: 3);
  static const Duration _cleanupInterval = Duration(seconds: 10);

  IframeController({
    required void Function(String message, {bool isError}) showMessage,
    required void Function() onReady,
    required String type,
    this.initialValue,
    void Function(double height)?
    onHeightChanged, // Add height callback parameter
  }) : _onReady = onReady,
       _type = type,
       _onHeightChanged = onHeightChanged {
    // Start cleanup timer for old messages
    _startCleanupTimer();
  }

  // Getters
  InAppWebViewController? get controller => _controller;
  bool get isReady => _isReady;
  String get type => _type;

  // Set height callback after initialization
  void setHeightCallback(void Function(double height)? callback) {
    _onHeightChanged = callback;
  }

  // Start cleanup timer to remove old messages
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(_cleanupInterval, (timer) {
      _cleanupOldMessages();
    });
  }

  // Remove messages older than the debounce duration
  void _cleanupOldMessages() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    for (final entry in _recentMessages.entries) {
      if (now.difference(entry.value) > _debounceDuration) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _recentMessages.remove(key);
    }
  }

  // Dispose method to clean up resources
  void dispose() {
    _cleanupTimer?.cancel();
    _recentMessages.clear();
  }

  // Set controller
  void setController(InAppWebViewController controller) {
    _controller = controller;
    _setupJavaScriptHandlers();
  }

  // Setup JavaScript handlers
  void _setupJavaScriptHandlers() {
    if (_controller == null) return;

    // Handler for ready notification
    _controller!.addJavaScriptHandler(
      handlerName: 'onEditorReady',
      callback: (args) {
        _isReady = true;
        _onReady();
        // showMessage('$_type ready!');
        onIframeReady();
      },
    );

    // Handler for error reporting
    _controller!.addJavaScriptHandler(
      handlerName: 'onError',
      callback: (args) {
        if (args.isNotEmpty) {
          // showMessage('Error: ${args[0]}', isError: true);
        }
      },
    );

    // Handler for height changes
    _controller!.addJavaScriptHandler(
      handlerName: 'onHeightChanged',
      callback: (args) {
        if (args.isNotEmpty && _onHeightChanged != null) {
          try {
            final height = double.parse(args[0].toString());
            _onHeightChanged!(height);
          } catch (e) {
            // Handle parsing error
          }
        }
      },
    );

    // Setup additional handlers
    setupAdditionalHandlers();
  }

  // Send message to iframe
  Future<void> sendMessage(String type, Map<String, dynamic> data) async {
    if (_controller == null) return;

    final message = {
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _controller!.evaluateJavascript(
      source:
          '''
        if (window.handleFlutterMessage) {
          window.handleFlutterMessage(${jsonEncode(message)});
        } else {
          console.log('handleFlutterMessage not available');
        }
      ''',
    );
  }

  // Send command to iframe
  Future<void> sendCommand(String command, Map<String, dynamic> params) async {
    if (_controller == null) return;

    final commandData = {'command': command, 'params': params};

    await _controller!.evaluateJavascript(
      source:
          '''
        if (window.handleFlutterCommand) {
          window.handleFlutterCommand(${jsonEncode(commandData)});
        } else {
          console.log('handleFlutterCommand not available');
        }
      ''',
    );
  }

  // Get content height from webview
  Future<double?> getContentHeight() async {
    if (_controller == null) return null;

    try {
      final result = await _controller!.evaluateJavascript(
        source: '''
          (function() {
            const body = document.body;
            const html = document.documentElement;
            const height = Math.max(
              body.scrollHeight,
              body.offsetHeight,
              html.clientHeight,
              html.scrollHeight,
              html.offsetHeight
            );
            return height;
          })();
        ''',
      );

      if (result != null) {
        return double.tryParse(result.toString());
      }
    } catch (e) {
      // Handle error
    }

    return null;
  }

  // Request height update from webview
  Future<void> requestHeightUpdate() async {
    if (_controller == null) return;

    await _controller!.evaluateJavascript(
      source: '''
        if (window.requestHeightUpdate) {
          window.requestHeightUpdate();
        } else {
          // Fallback: manually calculate and send height
          const height = Math.max(
            document.body.scrollHeight,
            document.body.offsetHeight,
            document.documentElement.clientHeight,
            document.documentElement.scrollHeight,
            document.documentElement.offsetHeight
          );
          if (window.flutter_inappwebview) {
            window.flutter_inappwebview.callHandler('onHeightChanged', height);
          }
        }
      ''',
    );
  }

  // Send app settings
  Future<void> sendAppSettings() async {
    if (!_isReady) {
      // showMessage('$_type not ready yet', isError: true);
      return;
    }

    final String theme =
        ThemeModeReadWriteValue.instance.value?.name ?? 'light';
    final String language =
        LocaleReadWriteValue.instance.value?.languageCode ?? 'en';
    await sendCommand('setAppSettings', {'theme': theme, 'language': language});
    // showMessage('App settings sent to $_type');
  }

  // Setup Flutter bridge
  Future<void> setupFlutterBridge() async {
    if (_controller == null) return;

    await _controller!.evaluateJavascript(
      source:
          '''
        console.log('$_type loaded, setting up Flutter bridge');
        window.isFlutterBridgeReady = true;
        
        // Dispatch bridge ready event
        if (window.dispatchEvent) {
          window.dispatchEvent(new Event('flutterBridgeReady'));
        }
      ''',
    );
  }

  // Abstract methods to be implemented by subclasses
  void setupAdditionalHandlers();
  void onIframeReady();

  // Protected method for subclasses to show messages with debouncing
  // void showMessage(String message, {bool isError = false}) {
  //   if (_shouldShowMessage(message)) {
  //     _showMessage(message, isError: isError);
  //   }
  // }
}
