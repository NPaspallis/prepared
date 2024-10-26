import 'package:app/schema/component/branch_component.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

///A component that allows the user to view HTML-formatted content.
class BranchComponentView extends StatefulWidget {

  final String storyId;
  final BranchComponent component;

  const BranchComponentView(this.storyId, this.component, {super.key});

  @override
  State<BranchComponentView> createState() => _BranchComponentViewState();
}

class _BranchComponentViewState extends State<BranchComponentView> {

  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if(request.url.startsWith("file://") || request.url.startsWith("https://storage.googleapis.com")) {
              return NavigationDecision.navigate;
            } else if(request.url.startsWith('http')) {
              _launchURL(request.url);
              return NavigationDecision.prevent;
            } else {
              return NavigationDecision.navigate;
            }
          }
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

    //Multiple linked components, show content and options:
    if (widget.component.choices.length > 1 && widget.component.content != null) {
print('widget.component.content: ${widget.component.content}');
      if(widget.component.content!.toLowerCase().startsWith("html::")) {
        _webViewController.loadFlutterAsset(widget.component.content!.substring(6));
      }
      else if (widget.component.content!.toLowerCase().startsWith("http")) {
        _webViewController.loadRequest(Uri.parse(widget.component.content!));
      }
      else {
        _webViewController.loadHtmlString(widget.component.content!);
      }

      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            //Content:
            SizedBox(
              height: MediaQuery.of(context).size.height / 1.3, //TODO - May need adjustment
              child: WebViewWidget(
                  controller: _webViewController,
              ),
            ),

          ],
        ),
      );
    }
    else {
      //1 component only, redirect to it
      if (widget.component.choices.isNotEmpty) {
        String linkedComponentID = widget.component.choices[0].linkedComponentID;
        //TODO - Navigate to this component.
        return Container();
      }
      //No components:
      else {
        //Note: This should be safeguarded in validation_utils.dart:checkStoryReferences(), but just making sure:
        return ErrorWidget(Text("Branch Component error (ID: '${widget.component.id}'): No link to another component."));
      }
    }


  }
}
