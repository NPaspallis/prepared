import 'package:app/schema/component/audio_component.dart';
import 'package:app/ui/widgets/audio_player_widget.dart';
import 'package:app/ui/widgets/video_player_widget.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../model/story_progress.dart';
import '../../schema/component/video_component.dart';
import '../../util/audio_utils.dart';

///A component that allows the user to view a video (with content).
class AudioComponentView extends StatefulWidget {

  final String storyId;
  final AudioComponent component;

  const AudioComponentView(this.storyId, this.component, {super.key});

  @override
  State<AudioComponentView> createState() => _AudioComponentViewState();
}

class _AudioComponentViewState extends State<AudioComponentView> with WidgetsBindingObserver {

  WebViewController? _webViewController;
  final audioPlayer = AudioPlayer();
  late Duration duration;

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

  //https://pub.dev/packages/just_audio/example
  Future<void> _loadAudioPlayer() async {

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    audioPlayer.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
         print('A stream error occurred: $e');
    });

    try {
      duration = (await audioPlayer.setUrl(widget.component.audioURL))!;
      final audioSource = LockCachingAudioSource(Uri.parse(
          widget.component.audioURL)); //Enable caching of the audio file
      await audioPlayer.setAudioSource(audioSource);

      audioPlayer.positionStream.listen((event) {

        //Consider audio component completed if audio has been listened to >75%:
        if (event.inSeconds > audioSource.duration!.inSeconds * (3/4)) {
          Provider.of<StoryProgress>(context, listen: false)
              .setCompleted(widget.storyId, widget.component.id, true);
        }

      },);

    } on PlayerException catch (e) {
      print("Error loading audio source: $e");
      Fluttertoast.showToast(msg: "The audio could not be played");
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

    ambiguate(WidgetsBinding.instance)!.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _loadAudioPlayer();

    _loadWebView().then((value) => setState(() {}));
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
    ambiguate(WidgetsBinding.instance)!.removeObserver(this);
    audioPlayer.stop();
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      audioPlayer.stop();
    }
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          audioPlayer.positionStream,
          audioPlayer.bufferedPositionStream,
          audioPlayer.durationStream,
              (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return audioPlayer == null || _webViewController == null ?
    const AspectRatio(
      aspectRatio: 1,
      child: CircularProgressIndicator(),
    ) :
    OrientationBuilder(
      builder: (context, orientation) => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AudioPlayerWidget(audioPlayer),
          Visibility(
            visible: orientation == Orientation.portrait,
            child: Expanded(child: WebViewWidget(controller: _webViewController!))
          )
        ],
      )
    );
  }
}

