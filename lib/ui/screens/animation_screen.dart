import 'package:app/ui/widgets/buttons.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../styles/style.dart';

///A screen that shows the animation video for the project.
class AnimationScreen extends StatefulWidget {

  const AnimationScreen({super.key});

  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen> {

  late VideoPlayerController videoController;
  ChewieController? chewieController;

  Future<ChewieController> loadVideoPlayer() async {
    //Initialize the controller:
    videoController = VideoPlayerController.asset('assets/onboarding/prepared-animation-720p.mp4');

    await videoController.initialize();

    //Initialize the Chewie controller:
    ChewieController chewieController = ChewieController(
      videoPlayerController: videoController,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
      ],
      startAt: const Duration(milliseconds: 0),
      autoPlay: true,
      looping: false,
      materialProgressColors: ChewieProgressColors(
          backgroundColor: Colors.black,
          bufferedColor: Colors.grey,
          handleColor: primaryColor,
          playedColor: secondaryColor
      ),
      aspectRatio: videoController.value.aspectRatio,
    );

    chewieController.videoPlayerController.addListener(() {
      //Show controls once the video elapses:
      if (chewieController.videoPlayerController.value.position == chewieController.videoPlayerController.value.duration) {
        chewieController.seekTo(const Duration(seconds: 0));
        chewieController.pause();
        //If in fullscreen mode and video ends, go back to portrait mode:
        chewieController.exitFullScreen();
      }
    }); // end of listener

    return chewieController;
  }

  @override
  void initState() {
    super.initState();
    loadVideoPlayer().then((chewieController) => setState(() => this.chewieController = chewieController));
  }

  @override
  void dispose() {
    videoController.dispose();
    chewieController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Which project developed this app'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).popUntil(ModalRoute.withName('/about')),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: OrientationBuilder(
            builder: (context, orientation) => orientation == Orientation.portrait
                ? Column(
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width / videoController.value.aspectRatio,
                    child: chewieController == null
                        ? const Center(child: CircularProgressIndicator())
                        : Chewie(controller: chewieController!)
                ),
                const SizedBox(height: 16),
                createButtonWithIcon(
                    'View video in full screen',
                    const Icon(Icons.fullscreen),
                        () => chewieController?.enterFullScreen(),
                    key: const Key('button-view-animation-video-full-screen'))
              ],
            ) : SizedBox(
                height: MediaQuery.of(context).size.width / videoController.value.aspectRatio,
                child: Chewie(controller: chewieController!)
            ),
          )
        )
    );
  }
}