import 'package:app/ui/styles/style.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../model/story_progress.dart';
import '../../schema/component/video_component.dart';
import '../../util/file_utils.dart';
import '../component_views/video_component_view.dart';
import 'buttons.dart';

///Custom video player that enables videos to be played from assets or remote resources.
///Supports subtitles.
class VideoPlayerWidget extends StatefulWidget {

  final VideoComponent component;
  final VideoComponentView view;

  const VideoPlayerWidget(this.component, this.view, {super.key});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {

  late VideoPlayerController videoController;
  ChewieController? chewieController;

  Future<ChewieController?> loadVideoPlayer() async {

    try {
      //Initialize the controller:
      if (widget.component.videoURL.startsWith("https://") ||
          widget.component.videoURL.startsWith("http://")) { //Network video
        final Uri uri = Uri.parse(widget.component.videoURL);
        videoController = VideoPlayerController.networkUrl(uri);
      }
      else { //Asset video
        final String videoUrl = widget.component.videoURL;
        videoController = VideoPlayerController.asset(videoUrl);
      }

      await videoController.initialize();

      //Load subtitles if a file is provided:
      Subtitles? subtitles;
      if (widget.component.subtitlesURL != null &&
          widget.component.subtitlesURL!.isNotEmpty) {
        subtitles = await FileUtils.loadSubtitlesFromFile(widget.component.subtitlesURL!);
      }

      //Set start time (if null or bigger than video then set to 0)
      int startTime = 0;
      if (widget.component.startTime != null) {
        if (widget.component.startTime! <
            videoController.value.duration.inMilliseconds) {
          startTime = widget.component.startTime!;
        }
      }

      //Set end time
      int endTime = 0;
      if (widget.component.endTime != null) {
        //If positive & bigger than video then set to video duration
        if (widget.component.endTime! >= 0) {
          if (widget.component.endTime! <
              videoController.value.duration.inMilliseconds) {
            widget.component.endTime!;
          }
          else {
            endTime = videoController.value.duration.inMilliseconds;
          }
        }
        else {
          //If negative & bigger than video then set to video duration
          if (widget.component.endTime!.abs() >
              videoController.value.duration.inMilliseconds) {
            endTime = videoController.value.duration.inMilliseconds;
          }
          //If negative & smaller than video then go backwards from the video duration.
          else {
            endTime = videoController.value.duration.inMilliseconds +
                widget.component.endTime!;
          }
        }
      }
      else {
        endTime = videoController.value.duration.inMilliseconds;
      }

      //Initialize the Chewie controller:
      ChewieController chewieController = ChewieController(
        videoPlayerController: videoController,
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
        ],
        startAt: Duration(milliseconds: startTime),
        autoPlay: false,
        looping: false,
        // zoomAndPan: true,
        subtitle: subtitles,
        subtitleBuilder: (context, subtitle) {
          return Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                shadows: [
                  Shadow(
                      color: Colors.black,
                      blurRadius: 2,
                      offset: Offset(1, 1)
                  )
                ],
                fontSize: 14,
                color: Colors.white
            ),
          );
        },
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
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
        if (chewieController.videoPlayerController.value.position ==
            chewieController.videoPlayerController.value.duration) {
          chewieController.seekTo(const Duration(seconds: 0));
          chewieController.pause();
          //If in fullscreen mode and video ends, go back to portrait mode:
          chewieController.exitFullScreen();
        }

        //Consider video watched, if it has been watched up to X seconds before its end:
        if (chewieController.videoPlayerController.value.position
            .inMilliseconds >= endTime) {
          Provider.of<StoryProgress>(context, listen: false)
              .setCompleted(
              widget.view.storyId, widget.view.component.id, true);
          // if (kDebugMode) {
          //   print("${widget.view.component.id} -> ${true}");
          // }
        }
      }); //end of listener

      return chewieController;
    }
    catch (error) {
      debugPrint('$error');
      return null;
    }
  }

  bool _showError = false;

  @override
  void initState() {
    super.initState();
    loadVideoPlayer().then((chewieController) => setState(() {
      if (chewieController != null) {
        this.chewieController = chewieController;
      }
      else {
        _showError = true;
      }
    }));
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
    if (!_showError) {
      return OrientationBuilder(
        builder: (context, orientation) =>
        orientation == Orientation.portrait ?
        Column( // portrait mode
          children: [
            SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .width / videoController.value.aspectRatio,
              child: Center(
                  child: chewieController != null &&
                      chewieController!.videoPlayerController.value
                          .isInitialized
                      ? Chewie(controller: chewieController!,)
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text("Loading video...")
                    ],
                  )
              ),
            ),
            const SizedBox(height: 16),
            createButtonWithIcon(
                'View video in full screen',
                const Icon(Icons.fullscreen),
                    () => chewieController!.enterFullScreen(),
                key: const Key('button-view-animation-video-full-screen')),
          ],
        ) :
        Center(
            child: chewieController != null &&
                chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: chewieController!,)
                : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Loading video...")
              ],
            )
        ),
      );
    }
    else {
      //Allow users to proceed to next component if there is an error:
      Provider.of<StoryProgress>(context, listen: false)
          .setCompleted(
          widget.view.storyId, widget.view.component.id, true);
      return buildErrorScreen();
    }
  }

  ///Builds the error (disconnected) screen.
  Widget buildErrorScreen() {
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 25.0),
        child: Column(
          children: [
            Icon(Icons.error, color: Colors.red, size: 50,),
            SizedBox(height: 20,),
            Text("The video could not be loaded.", textAlign: TextAlign.center),
            SizedBox(height: 20,),
            Text("An error prevents this video from being displayed. Please make sure you have an Internet connection.", textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}