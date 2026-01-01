import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../../services/connectivity_service/connectivity_controller.dart';
import 'controllers/renderer_controller.dart';
import 'widgets/renderer_widget.dart';

class GlobalHtmlViewWidget extends StatefulWidget {
  final String? data;
  final Color? fillColor;
  final double? height;
  final Function(String id, String tag)? goToArticleDetailsScreen;

  final OnLoadingBuilder? onLoadingBuilder;
  final bool buildAsync;

  GlobalHtmlViewWidget({
    required this.data,
    this.fillColor,
    this.height,
    this.goToArticleDetailsScreen,
    this.onLoadingBuilder,
    this.buildAsync = true,
  }) : super(key: ValueKey(data));

  @override
  State<GlobalHtmlViewWidget> createState() => _GlobalHtmlViewWidgetState();
}

class _GlobalHtmlViewWidgetState extends State<GlobalHtmlViewWidget> {
  RendererController? _rendererController;
  String? _lastData;
  double? _currentHeight;

  void _showMessage(String message, {bool isError = false}) {
    // Get.snackbar(
    //   ' Notification',
    //   message,
    //   backgroundColor: isError ? Colors.red : Colors.green,
    //   duration: const Duration(seconds: 2),
    // );
  }

  void _onHeightChanged(double height) {
    if (mounted) {
      setState(() {
        _currentHeight = height;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _lastData = widget.data;
    _rendererController = RendererController(
      showMessage: _showMessage,
      initialValue: widget.data,
      onReady: () => {},
      onHeightChanged: _onHeightChanged,
    );
  }

  @override
  void didUpdateWidget(GlobalHtmlViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // تحديث المحتوى إذا تغير
    if (widget.data != _lastData && _rendererController != null) {
      _lastData = widget.data;
      _rendererController!.setHtmlContent(widget.data ?? '');
    }
  }

  @override
  void dispose() {
    _rendererController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the height to use
    double height =
        _currentHeight ??
        widget.height ??
        MediaQuery.of(context).size.height * 0.5;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: height,
      child:
          ConnectivityService.instance.connectionStatus.value !=
              ConnectivityResult.none
          ? _rendererController != null
                ? RendererWidget(controller: _rendererController!)
                : const Center(child: CircularProgressIndicator())
          : HtmlWidget('<div>${widget.data}</div>'),
    );
  }
}
