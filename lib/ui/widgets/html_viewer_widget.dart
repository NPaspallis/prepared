import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

///A widget that displays to the user the EULA.
class HtmlViewerWidget extends StatefulWidget {

  final String assetUrl;

  const HtmlViewerWidget(this.assetUrl, {super.key});

  @override
  State<HtmlViewerWidget> createState() => _HtmlViewerWidgetState();
}

class _HtmlViewerWidgetState extends State<HtmlViewerWidget> {

  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              return NavigationDecision.navigate;
            },
          )
      );
    _webViewController.loadFlutterAsset(widget.assetUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            margin: const EdgeInsets.all(10),
            child: WebViewWidget(
                controller: _webViewController
            )
        ));
  }
}
