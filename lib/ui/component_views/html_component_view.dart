import 'package:app/schema/component/html_component.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

///A component that allows the user to view HTML-formatted content.
class HtmlComponentView extends StatefulWidget {

  final String storyId;
  final HtmlComponent component;

  const HtmlComponentView(this.storyId, this.component, {super.key});

  @override
  State<HtmlComponentView> createState() => _HtmlComponentViewState();
}

class _HtmlComponentViewState extends State<HtmlComponentView> {

  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if(request.url.startsWith("file://") || request.url.startsWith("https://storage.googleapis.com")) {
              return NavigationDecision.navigate;
            } else {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            }
          },
        )
      );
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {

    if(widget.component.content.toLowerCase().startsWith("html::")) {
      _webViewController.loadFlutterAsset(widget.component.content.substring(6));
    }
    else if (widget.component.content.toLowerCase().startsWith("http")) {
      _webViewController.loadRequest(Uri.parse(widget.component.content));
    }
    else {
      _webViewController.loadHtmlString(widget.component.content);
    }

    return WebViewWidget(
      controller: _webViewController
    );
  }
}
