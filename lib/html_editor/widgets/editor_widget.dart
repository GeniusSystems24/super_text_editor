import 'package:control_management_systems/main_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:recase/recase.dart';

import '../controllers/editor_controller.dart';

class EditorScreen extends StatefulWidget {
  final EditorController controller;
  final String? baseUrl = 'https://clubapp.com';
  final String labelText;

  const EditorScreen({
    super.key,
    required this.controller,
    required this.labelText,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen>
    with AutomaticKeepAliveClientMixin<EditorScreen> {
  @override
  bool get wantKeepAlive => true;

  bool inReady = false;
  double progress = 0.0;
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.labelText),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              Navigator.of(context).pop(widget.controller.lastContent);

              if (widget.controller.lastContent == '' ||
                  widget.controller.lastContent ==
                      widget.controller.initialValue) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.tr.successfullyDone("").sentenceCase),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri('${widget.baseUrl}/iframe/editor'),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                allowsInlineMediaPlayback: true,
                mediaPlaybackRequiresUserGesture: false,
                supportZoom: false,
                algorithmicDarkeningAllowed:
                    Theme.of(context).brightness == Brightness.dark
                    ? true
                    : false, // Enable dark mode if the app is in dark theme
              ),
              onWebViewCreated: (controller) async {
                widget.controller.setController(controller);
              },
              onLoadStop: (controller, url) {
                widget.controller.setupFlutterBridge();
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  this.progress = progress / 100.0;
                });
                if (progress == 100) {
                  setState(() {
                    inReady = true;
                  });
                }
              },
            ),
          ),
          if (progress < 1.0)
            LinearProgressIndicator(
              value: progress,
              color: isDarkMode ? Colors.blue : Colors.green,
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            ),
        ],
      ),
    );
  }
}
