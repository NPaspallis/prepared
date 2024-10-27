import 'dart:async';
import 'dart:math';

import 'package:app/model/story_backstack.dart';
import 'package:app/model/story_progress.dart';
import 'package:app/schema/component/audio_component.dart';
import 'package:app/schema/component/badge_component.dart';
import 'package:app/schema/component/branch_component.dart';
import 'package:app/schema/component/bucket_component.dart';
import 'package:app/schema/component/component.dart';
import 'package:app/schema/component/html_component.dart';
import 'package:app/schema/component/mcq_component.dart';
import 'package:app/schema/component/multimcq_component.dart';
import 'package:app/schema/component/multipoll_component.dart';
import 'package:app/schema/component/exam_component.dart';
import 'package:app/schema/component/video_component.dart';
import 'package:app/ui/component_views/audio_component_view.dart';
import 'package:app/ui/component_views/badge_component_view.dart';
import 'package:app/ui/component_views/html_component_view.dart';
import 'package:app/ui/component_views/poll_component_view.dart';
import 'package:app/ui/component_views/video_component_view.dart';
import 'package:app/ui/styles/style.dart';
import 'package:app/ui/widgets/update_app_widget.dart';
import 'package:app/util/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../../model/abstract_stack.dart';
import '../../schema/component/component_choice.dart';
import '../../schema/component/component_type.dart';
import '../../schema/component/discussion_component.dart';
import '../../schema/component/poll_component.dart';
import '../../schema/story.dart';
import '../../util/pref_utils.dart';
import '../component_views/branch_component_view.dart';
import '../component_views/bucket_component_view.dart';
import '../component_views/discussion_component_view.dart';
import '../component_views/mcq_component_view.dart';
import '../component_views/multimcq_component_view.dart';
import '../component_views/multipoll_component_view.dart';
import '../component_views/exam_component_view.dart';

///A screen that allows the user to view the components of a story and interact with
///UI elements to progress through the story.
class ViewStoryScreen extends StatefulWidget {
  final Story story;

  @override
  State<ViewStoryScreen> createState() => _ViewStoryScreenState();

  const ViewStoryScreen(this.story, {super.key});
}

class _ViewStoryScreenState extends State<ViewStoryScreen> {

  final Map<String, StoryComponent> _components = {}; //Component ID -> Component

  int _maxCompletedIndex = 0;
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  bool hasInternet = false;
  late StreamSubscription<InternetStatus> internetListener;

  late AbstractStack<int> _backstack;

  String _getKeyMaxCompletedIndex(String storyId) {
    return '${PreferenceUtils.keyMaxCompletedIndex}-$storyId';
  }

  String _getKeyCurrentIndex(String storyId) {
    return '${PreferenceUtils.keyCurrentIndex}-$storyId';
  }

  static const ticksPerSecond = 10;
  static const secondsToShowTooltip = 3;
  static const maxTooltipCountdown = secondsToShowTooltip * ticksPerSecond;
  late Timer timer;
  int tooltipCountdown = 0;
  String tooltip = '';

  void showTooltip(final String tooltip) {
    setState(()  {
      this.tooltip = tooltip;
      tooltipCountdown = maxTooltipCountdown;
    });
  }

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(milliseconds: (1000 / ticksPerSecond).round()), (timer) {
      setState(() {
        tooltipCountdown--;
        if(tooltipCountdown < 0) {
          tooltipCountdown = 0;
        }
      });
    });

    //Load the components:
    for(StoryComponent storyComponent in widget.story.components) {
      _components[storyComponent.getID()] = storyComponent;
    }

    //Load the backstack:
    _loadBackstack().then((_) {
      //If a backstack exists and is not empty, try to load the top element.
      if (_backstack.isNotEmpty()) {
        _currentIndex = _backstack.peek();
      }
      //If the backstack for this story is null or empty, create it, and then push the starting component in it
      else {
        _currentIndex = widget.story.getIndexOfStartingComponent()!;
        _backstack.push(_currentIndex);
      }

      //Save the initial backstack
      StoryBackstack.saveToPrefs(widget.story.id, _backstack);

      //Set max completed index and jump to correct component.
      SharedPreferences.getInstance().then((prefs) {
        setState(() {
          _maxCompletedIndex = prefs.getInt(_getKeyMaxCompletedIndex(widget.story.id)) ?? 0;
          _pageController.jumpToPage(_currentIndex);
        });
      });
    },);

    Dialog internetDialog = Dialog(
      child: UIUtils.noInternetOverlay(() {
        InternetConnection().hasInternetAccess.then((value) {
          hasInternet = value;
          if (hasInternet) {
            Navigator.pop(context);
          }
        },);
      }),
    );

    internetListener = InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          hasInternet = true;
          break;
        case InternetStatus.disconnected:
          hasInternet = false;
          showDialog(
              context: context,
              builder: (context) => internetDialog,
              barrierDismissible: false,
          );
          break;
      }
    });

  }

  //Loads the backstack, either from prefs or by creating a new backstack for this story.
  Future<void> _loadBackstack() async {
    AbstractStack<int>? stack = await StoryBackstack.loadFromPrefs(widget.story.id);
    stack ??= AbstractStack<int>();
    _backstack = stack;
  }

  @override
  void dispose() {
    // save current index and max completed index:
    SharedPreferences.getInstance().then((prefs) {
      prefs.setInt(_getKeyMaxCompletedIndex(widget.story.id), _maxCompletedIndex);
      StoryBackstack.saveToPrefs(widget.story.id, _backstack); //TODO Creates an error??
    });
    internetListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.story.shortTitle)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _components.isEmpty ?
                const CircularProgressIndicator() :
                PageView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  itemCount: _components.length,
                  itemBuilder: (context, index) {
                    StoryComponent? storyComponent = _components.values.toList()[index];
                    return _getComponentView(storyComponent);
                  },
                  onPageChanged: (index) => setState(() {
                    _currentIndex = index;
                    _maxCompletedIndex = max(_maxCompletedIndex, _currentIndex);
                  }),
                ),
            ),

            LinearProgressIndicator(
              value: (_currentIndex + 1.0) / _components.length,
            ),
            LinearProgressIndicator(
              value: (_maxCompletedIndex + 1.0) / _components.length,
              color: secondaryColor,
            ),

            _getBottomNavigationView(),

            // show tooltip
            tooltipCountdown > 0 ?
                Stack(
                  children: [
                    LinearProgressIndicator(
                      value: tooltipCountdown / maxTooltipCountdown,
                      color: Colors.black12,
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Text(tooltip, style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ],
                )
                : Container()
          ]
        ),
    );
  }

  ///Constructs the bottom navigation view based on the component being viewed.
  Widget _getBottomNavigationView() {

    //Branch components will show a different (branching) navigation menu
    if (widget.story.components[_currentIndex].getType() == ComponentType.branch) {
      BranchComponent branchComponent = widget.story.components[_currentIndex] as BranchComponent;

      List<Consumer> optionWidgets = [
        //First entry is always the back button widget:
        Consumer<StoryProgress>(
          builder: (context, storyProgress, child) {
            return OutlinedButton(
              onPressed: _currentIndex == 0 ? null : _previous,
              child: const Icon(Icons.skip_previous),
            );
          },
        )
      ];

      for (ComponentChoice choice in branchComponent.choices) {

        Consumer<StoryProgress> consumer = Consumer(
          builder: (context, storyProgress, child) {
            return OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () async {
                //Find the appropriate index:
                int? nextComponentIndex = widget.story.getComponentIndex(choice.linkedComponentID);
                if (nextComponentIndex != null) {
                  //Go to the component, if it exists:
                  _backstack.push(nextComponentIndex);
                  StoryBackstack.saveToPrefs(widget.story.id, _backstack);
                  setState(() {
                    _currentIndex = nextComponentIndex;
                    _pageController.jumpToPage(_currentIndex);
                  });
                }
                else {
                  UIUtils.showErrorToast("The component referenced by this branch element ('${branchComponent.id}') does not exist.");
                }
              },
              child: Text(choice.label, style: const TextStyle(fontSize: 16)),
            );
          },
        );
        
        //Construct consumer:
        optionWidgets.add(consumer);
      }

      return SafeArea(
          child: Container(
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1))
            ),
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: optionWidgets,
            ),
          ),
        );
    }

    //Generic navigation menu (sequential progression)
    else {
      return SafeArea(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                children: [
                  Consumer<StoryProgress>(
                    builder: (context, storyProgress, child) {
                      return OutlinedButton(
                        onPressed: _currentIndex == 0 ? null : _previous,
                        child: const Icon(Icons.skip_previous),
                      );
                    },
                  ),
                  Expanded(
                      child: Text("${_currentIndex+1} / ${_components.length}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold))
                  ),
                  Container(width: 10),
                  Consumer<StoryProgress>(
                      builder: (context, storyProgress, child) {
                        final StoryComponent currentStoryComponent = widget.story.components[_currentIndex];
                        bool componentCompleted = storyProgress.isCompleted(widget.story.id, currentStoryComponent.getID());
                        if(!componentCompleted && currentStoryComponent.getType() == ComponentType.html) { // if an html component, and not completed, start a count-down
                          Future.delayed(const Duration(seconds: 1), (){
                            storyProgress.setCompleted(widget.story.id, currentStoryComponent.getID(), true);
                          });
                        }
                        bool lastComponent = _currentIndex >= _components.length - 1;
                        String tooltip = _getTooltipByComponentType(currentStoryComponent.getType());
                        return lastComponent ?
                        _getOutlinedButtonWithTooltip(componentCompleted, _finish, 'Finish', Icons.check, tooltip, showTooltip) :
                        _getOutlinedButtonWithTooltip(componentCompleted, _next, null, Icons.skip_next, tooltip, showTooltip);
                      }
                  )
                ],
              )
          )
      );
    }

  }

  String _getTooltipByComponentType(ComponentType componentType) {
    switch(componentType) {
      case ComponentType.video: return 'The button will be enabled after you watch the video';
      case ComponentType.audio: return 'The button will be enabled after you listen to the audio';
      case ComponentType.poll: return 'The button will be enabled after you cast your vote';
      case ComponentType.mcq: return 'The button will be enabled after you provide an answer.';
      case ComponentType.multipoll: return 'The button will be enabled after you provide an answer.';
      case ComponentType.discussion: return 'The button will be enabled after you view the discussion messages';
      case ComponentType.bucket: return 'The button will be enabled after you have completed the exercise';
      case ComponentType.exam: return 'Please pass the exam before proceeding';
      case ComponentType.badge:
      case ComponentType.chat:
      case ComponentType.html:
      default: return 'The button will be enabled after you view the page';
    }
  }

  Widget _getOutlinedButtonWithTooltip(bool active, VoidCallback action, String? label, IconData? iconData, String tooltipMessage, Function(String) showTooltip) {
    final List<Widget> rowChildren = [];
    if(label != null) rowChildren.add(Text(label));
    if(iconData != null) rowChildren.add(Icon(iconData));

    // SnackBar snackBarTooltip = SnackBar(
    //   behavior: SnackBarBehavior.floating,
    //     margin: const EdgeInsets.only(bottom: 80.0),
    //     content: Text(tooltipMessage),
    //     dismissDirection: DismissDirection.none,
    //     backgroundColor: const Color(0x60000000),
    // );

    return GestureDetector(
        onTap: () {
          // ScaffoldMessenger.of(context).showSnackBar(snackBarTooltip);
          showTooltip(tooltipMessage);
        },
        child: OutlinedButton(
            onPressed: active ? action : null,
            child: Row(
                children: rowChildren
            )
        )
    );
  }

  void _previous() {
    int previousIndex = _backstack.peek();
    _backstack.pop();
    _currentIndex = _backstack.peek();
    StoryBackstack.saveToPrefs(widget.story.id, _backstack);

    //If page is adjacent, animate to it, otherwise don't do an animation:
    if (previousIndex == _backstack.peek() + 1) {
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn
      );
    }
    else {
      _pageController.jumpToPage(
        _currentIndex,
      );
    }

    setState(() => tooltipCountdown = 0);
  }

  void _next() {
    _currentIndex += 1;
    _backstack.push(_currentIndex);
    StoryBackstack.saveToPrefs(widget.story.id, _backstack);

    _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn
    );
  }

  void _finish() {
    _backstack.clear();
    StoryBackstack.saveToPrefs(widget.story.id, _backstack);
    _currentIndex = widget.story.getIndexOfStartingComponent()!; // reset index to point to first page
    Navigator.of(context).pop(); // exit to main screen

    //Save completion of story:
    SharedPreferences.getInstance().then((value) {
      value.setBool(PreferenceUtils.constructStoryCompletionKey(widget.story.id), true);
    },);
  }

  ///Constructs each component view.
  Widget _getComponentView(StoryComponent component) {
    switch (component.getType()) {
      case ComponentType.html:
        HtmlComponent htmlComponent = component as HtmlComponent;
        return HtmlComponentView(widget.story.id, htmlComponent);

      case ComponentType.chat:
        return const Text("Chat Component"); // todo implement

      case ComponentType.poll:
        PollComponent pollComponent = component as PollComponent;
        return PollComponentView(widget.story.id, pollComponent);

      case ComponentType.multipoll:
        MultipollComponent multipollComponent = component as MultipollComponent;
        return MultipollComponentView(widget.story.id, multipollComponent);

      case ComponentType.mcq:
        MCQComponent mcqComponent = component as MCQComponent;
        return MCQComponentView(widget.story.id, mcqComponent);

      case ComponentType.multimcq:
        MultiMCQComponent multiMCQComponent = component as MultiMCQComponent;
        return MultiMCQComponentView(widget.story.id, multiMCQComponent);

      case ComponentType.discussion:
        DiscussionComponent discussionComponent = component as DiscussionComponent;
        return DiscussionComponentView(widget.story.id, discussionComponent);

      case ComponentType.video:
        VideoComponent videoComponent = component as VideoComponent;
        return VideoComponentView(widget.story.id, videoComponent);

      case ComponentType.branch:
        BranchComponent branchComponent = component as BranchComponent;
        return BranchComponentView(widget.story.id, branchComponent);

      case ComponentType.bucket:
        BucketComponent bucketComponent = component as BucketComponent;
        return BucketComponentView(widget.story.id, bucketComponent);

      case ComponentType.audio:
        AudioComponent audioComponent = component as AudioComponent;
        return AudioComponentView(widget.story.id, audioComponent);

      case ComponentType.badge:
        BadgeComponent badgeComponent = component as BadgeComponent;
        return BadgeComponentView(widget.story.id, badgeComponent);

      case ComponentType.exam:
        ExamComponent testComponent = component as ExamComponent;
        return ExamComponentView(widget.story.id, testComponent);

      default:
        return UpdateAppWidget(message: "Unknown component.");
    }
  }
}
