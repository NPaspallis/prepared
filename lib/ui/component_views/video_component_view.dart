import 'package:app/ui/widgets/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../schema/component/video_component.dart';

///A component that allows the user to view a video (with content).
class VideoComponentView extends StatefulWidget {

  final String storyId;
  final VideoComponent component;

  const VideoComponentView(this.storyId, this.component, {super.key});

  @override
  State<VideoComponentView> createState() => _VideoComponentViewState();
}

class _VideoComponentViewState extends State<VideoComponentView> {

  WebViewController? _webViewController;
  VideoPlayerWidget? _videoPlayerWidget;

  Future<void> _loadWebView() async {
    if(widget.component.content.toLowerCase().startsWith("html::")) {
      _webViewController!.loadFlutterAsset(widget.component.content.substring(6));
    }
    else if (widget.component.content.toLowerCase().startsWith("http")) {
      _webViewController!.loadRequest(Uri.parse(widget.component.content));
    }
    else {
      String content = widget.component.content;
      if (content.isEmpty) {
        content = "<p></p>"; //Load empty paragraph as placeholder.
      }
      _webViewController!.loadHtmlString(content);
    }
  }

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setNavigationDelegate(
          NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) {
                if(request.url.startsWith("file://") || request.url.startsWith("https://storage.googleapis.com")) {
                  return NavigationDecision.navigate;
                } else {
                  _launchURL(request.url);
                  return NavigationDecision.prevent;
                }
              }
          )
      );

    _loadWebView().then((value) => setState(() {
      _videoPlayerWidget = VideoPlayerWidget(widget.component, widget);
    }));
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _videoPlayerWidget == null || _webViewController == null ?
    const AspectRatio(
      aspectRatio: 1,
      child: CircularProgressIndicator(),
    ) :
    OrientationBuilder(
      builder: (context, orientation) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _videoPlayerWidget!,
          Visibility(
            visible: orientation == Orientation.portrait,
            child: Expanded(child: WebViewWidget(controller: _webViewController!))
          )
        ],
      )
    );
  }
}
