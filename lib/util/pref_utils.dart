import 'dart:math';

import 'package:app/ui/screens/view_stories_screen.dart';
import 'package:app/util/device_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/story_backstack.dart';
import '../model/story_progress.dart';
import '../schema/story.dart';
import 'db_utils.dart';

///A utility class that helps manage preferences.
class PreferenceUtils {

  static const String keyOnboardingCompleted = "onboarding-completed";
  static const String keyNickname = "nickname";
  static const String keyEulaTimestamp = "eulaTimestamp";
  static const String keyCurrentIndex = "currentIndex";
  static const String keyMaxCompletedIndex = "maxCompletedIndex";
  static const String keyCurrentDiscussionIndex = "currentDiscussionIndex";
  static const String keyCurrentBucketIndex = "currentBucketIndex";
  static const String keyCompletionMap = "keyCompletionMap";
  static const String keyDeviceID = "keyDeviceID";
  static const String keyStoryCompleted = "keyStoryCompleted";
  static const String keyShowUnpublishedCaseStudies = "keyShowUnpublishedCaseStudies";
  static const String keyCurrentQuestionIndex = "currentQuestionIndex";
  static const String keyCurrentQuestionAnswerIndex = "currentQuestionAnswerIndex";

  static String constructStoryBackstackKey(String storyID) {
    return "StoryBackstack#$storyID";
  }

  static String constructPollEntryID(String deviceID, String storyID, String pollID) {
    return "$deviceID#$storyID#$pollID";
  }

  static String constructStoryCompletionKey(String storyID) {
    return "$keyStoryCompleted#$storyID";
  }

  static String createRandomNickname() {
    final random = Random();
    var firstWords = ['black', 'white', 'pink', 'red', 'yellow', 'green', 'blue', 'purple', 'brown', 'orange', 'silver', 'gold', 'cyan', 'bronze', 'teal'];
    var secondWords = ['cat', 'dog', 'bear', 'lion', 'puma', 'tiger', 'panda', 'monkey', 'elephant', 'hippo', 'dolphin', 'rabbit', 'lizard', 'parrot', 'snake'];
    return '${firstWords[random.nextInt(firstWords.length)]}-${secondWords[random.nextInt(secondWords.length)]}';
  }

  static void saveNickname(String nickname) {
    // save in prefs
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(PreferenceUtils.keyNickname, nickname);
    });
  }

  //Resets a story's progress
  static Future<void> resetStoryProgress(Story story) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? installationID = await DeviceUtils.getInstallationID();

    //Delete all votes for all polls of this story:
    DBUtils.deleteAllPollVotes(installationID!, story);

    prefs.remove(PreferenceUtils.constructStoryCompletionKey(story.id));

    //Delete any discussion component progress:
    prefs.getKeys().forEach((element) {
      if (element.startsWith("${PreferenceUtils.keyCurrentDiscussionIndex}-${story.id}-")) {
        prefs.remove(element);
      }
    });

    //Delete any bucket component progress:
    prefs.getKeys().forEach((element) {
      if (element.startsWith("${PreferenceUtils.keyCurrentBucketIndex}-${story.id}-")) {
        prefs.remove(element);
      }
    });

    //Do NOT delete badge related data as the actual badges are not revoked on badgr

    //Delete any exam component progress
    prefs.getKeys().forEach((element) {
      if (element.startsWith("${PreferenceUtils.keyCurrentQuestionIndex}-${story.id}-")) {
        prefs.remove(element);
      }
      if (element.startsWith("${PreferenceUtils.keyCurrentQuestionAnswerIndex}-${story.id}-")) {
        prefs.remove(element);
      }
    });

    //Delete component completion states:
    StoryProgress.loadComponentCompletionManually().then((map) {
      Map<String, bool> completionData = map[story.id]!;
      completionData.clear();
      StoryProgress.saveComponentCompletionManually(map);
    });

    //Clear the backstack
    StoryBackstack.clear(story.id);

    //Delete the max index:
    prefs.remove('${PreferenceUtils.keyMaxCompletedIndex}-${story.id}');
  }

  ///Reset the progress of all stories.
  static Future<void> resetAllStories() async {
    List<Future> futures = [];
    for (Story? story in ViewStoriesScreen.stories) {
      Future<void> future = resetStoryProgress(story!);
      futures.add(future);
    }
    await Future.wait(futures);
  }

  static String constructBadgeClassDeviceID(String badgeClassId, String deviceID) {
    return "$deviceID#$badgeClassId";
  }
}