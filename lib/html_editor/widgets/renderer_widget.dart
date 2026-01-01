import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../bottom_sheet.dart';
import '../../../youtube_player_iframe_widget.dart';
import '../controllers/renderer_controller.dart';

class RendererWidget extends StatefulWidget {
  final RendererController controller;
  final String? baseUrl = 'https://clubapp.com';

  const RendererWidget({super.key, required this.controller});

  @override
  State<RendererWidget> createState() => _RendererWidgetState();
}

class _RendererWidgetState extends State<RendererWidget>
    with AutomaticKeepAliveClientMixin<RendererWidget> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return InAppWebView(
      initialUrlRequest: URLRequest(
        url: WebUri('${widget.baseUrl}/iframe/renderer'),
      ),
      initialSettings: InAppWebViewSettings(
        overScrollMode: OverScrollMode.IF_CONTENT_SCROLLS,
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true,
        supportZoom: false,
        allowsInlineMediaPlayback: true,
        mediaPlaybackRequiresUserGesture: false,
        algorithmicDarkeningAllowed:
            Theme.of(context).brightness == Brightness.dark
            ? true
            : false, // Enable dark mode if the app is in dark theme
      ),
      onWebViewCreated: (controller) =>
          widget.controller.setController(controller),
      onLoadStop: (controller, url) {
        widget.controller.setupFlutterBridge();
        // Request initial height after load
        Future.delayed(const Duration(milliseconds: 500), () {
          widget.controller.requestHeightUpdate();
        });
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url.toString();
        if (url.startsWith('http')) {
          return await buildBottomSheet(
            context: context,
            itemBuilder: (BuildContext context) {
              return AppYoutubePlayerIframe(
                url: url,
                autoPlay: true,
                mute: false,
              );
            },
          );
        }
        return NavigationActionPolicy.DOWNLOAD;
      },
    );
  }
}
