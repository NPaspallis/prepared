import 'package:app/util/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

///A widget that shows helpful information about the app.
class HelpWidget extends StatefulWidget {

  const HelpWidget({super.key});

  @override
  State<HelpWidget> createState() => _HelpWidgetState();
}

class _HelpWidgetState extends State<HelpWidget> {

  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setNavigationDelegate(
          NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) {
                if(request.url.startsWith("file://")) {
                  return NavigationDecision.navigate;
                } else {
                  UIUtils.launchURL(request.url);
                  return NavigationDecision.prevent;
                }
              },
          )
      );

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _webViewController.loadFlutterAsset('assets/help/help.html'));
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