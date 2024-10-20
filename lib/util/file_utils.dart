import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:app/schema/story_check_status.dart';
import 'package:app/util/pref_utils.dart';
import 'package:app/util/schema_validator.dart';
import 'package:app/util/time_utils.dart';
import 'package:app/util/validation_results.dart' as val_res;
import 'package:app/util/validation_utils.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart';
import 'package:json_schema/json_schema.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../app.dart';
import '../schema/story.dart';

enum Phase { lineIndex, timing, content }

const cloudStoriesUrl = 'https://storage.googleapis.com/prepared-project.appspot.com/stories/stories.json';
const assetStoriesUrl = 'assets/story/stories.json';

///A utility class that enables interactions with files
class FileUtils {

  /// Loads a text file.
  static Future<String> loadTextFile(String filename) async {
    //Load from http:
    if (filename.startsWith("http")) {
      Response response = await http.get(Uri.parse("$filename?rand=${Random().nextInt(10000)}"));
      if (response.statusCode == 200) {
        // debugPrint('...loaded... >${response.body.length > 40 ? response.body.substring(0, 40) : response.body}<');
        return response.body;
      }
    }
    //Load from assets:
    return rootBundle.loadString(filename);
  }

  // Loads a text file and converts its context into a JSON object:
  static dynamic loadJsonFile(String filename) async {
    String storyExampleText = await FileUtils.loadTextFile(filename);
    return jsonDecode(storyExampleText);
  }

  /// Loads all stories from stories.json:
  static Future<List<Story>?> loadStories() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool showUnpublished = prefs.getBool(PreferenceUtils.keyShowUnpublishedCaseStudies) ?? false;

    try {
      List<Story> stories = [];
      String storiesFileText;
      if(kReleaseMode) { // if release mode, load from cloud URL
        storiesFileText = await FileUtils.loadTextFile(cloudStoriesUrl); // load from cloud
      } else { // assert kDebugMode, load from assets
        if (kDebugMode) {
          print('Loading stories file locally from assets');
        }
        storiesFileText = await FileUtils.loadTextFile(assetStoriesUrl); // load from local assets - uncomment to allow locally loaded stories, e.g., in debug mode
      }
      var jsonObject = jsonDecode(storiesFileText);

      int schemaVersion = jsonObject["schemaVersion"] as int;
      if (PreparedApp.appSchemaVersion != schemaVersion) {
        if (kDebugMode) {
          print("Inconsistent schema version detected.");
        }
        PreparedApp.onlineDataSchemaVersion = schemaVersion;
        return null;
      }

      var storiesArray = jsonObject["stories"];

      for (int i = 0; i < storiesArray.length; i++) {
        bool showStory = false;
        if (storiesArray[i]["published"] != null) {
          if (storiesArray[i]["published"] as bool || showUnpublished) {
            showStory = true;
          }
        }
        else {
          if (kDebugMode) {
            showStory = true;
          }
        }
        if (showStory) {
          String file = storiesArray[i]["file"] as String;
          var storyJson = await loadJsonFile(file);
          val_res.ValidationResults validationResults = await SchemaValidator
              .validateStory(storyJson);
          if (validationResults.isValid) {
            Story story = Story.fromJson(storyJson);
            StoryCheckStatus checkStoryStatus = ValidationUtils
                .checkStoryReferences(story);
            if (checkStoryStatus == StoryCheckStatus.ok) {
              stories.add(story);
            } else {
              throw Exception("Error in story '${story.id}' with title '${story.title}'. "
                  "Story component references violate runtime checks. \n ${checkStoryStatus.errorMessage}");
            }
          }
          else {
            String errorMessage = "";
            int counter = 0;
            for (ValidationError error in validationResults.errors) {
              errorMessage +=
              "ERROR $counter:\n ${error.message} at ${error.instancePath}\n";
              counter++;
            }
            debugPrint(errorMessage);
            if (kDebugMode) {
              print("\n\n\n");
            }
            throw Exception("Validation errors:\n\n $errorMessage");
          }
        }
      }
      return stories;
    } catch (e, stacktrace) {
      if (kDebugMode) {
        print("Story loader error: $e");
        print(stacktrace);
      }
      return null;
    }
  }

  ///Loads HTML content either statically or from a file reference,
  ///given content from the widget component data.
  static Future<String> loadHTMLContentForVideoComponent(String componentContent) async {

    //Referenced HTML:
    if (componentContent.toLowerCase().startsWith("html::")) {
      debugPrint('1: loading local asset: ${componentContent.substring(6)}');
      return FileUtils.loadTextFile(componentContent.substring(6));
    }
    else if (componentContent.toLowerCase().startsWith("http")) {
      debugPrint('2: loading cloud asset: $componentContent');
      final String htmlContent = await FileUtils.loadTextFile(componentContent);
      return htmlContent;
    }
    //Inline HTML
    else {
      debugPrint('3: loading hardcoded asset: $componentContent');
      return componentContent;
    }
  }

  ///Loads subtitles from a file, given a file name, and returns the subtitles as
  ///a map of int (SECOND at which the subtitle should be displayed) to String (subtitle text).
  static Future<Subtitles> loadSubtitlesFromFile(String filename) async {
    List<Subtitle?> subtitles = [];
    String text;

    debugPrint("*subtitles* - filename: $filename");
    //Optionally gets the srt file from either internet or cache:
    if (filename.startsWith("http") || filename.startsWith("https")) {
      File file = await DefaultCacheManager().getSingleFile(filename);
      text = file.readAsStringSync();
    }
    //Otherwise get from assets:
    else {
      text = await loadTextFile(filename);
    }

    List<String> lines = text.split(Platform.lineTerminator);

    //If no subtitles present, return an empty map:
    if (lines.length < 3) {
      return Subtitles([]);
    }

    const arrow = '-->';
    Phase phase = Phase.lineIndex;

    int subtitleIndex = 0;
    Duration? startTimeDuration;
    Duration? endTimeDuration;
    String content = "";

    for(String line in lines) {

      // debugPrint('...phase: $phase --> line: $line');
      switch(phase) {
        case Phase.lineIndex:
          if(line.trim().isEmpty) { // an empty line at this point signifies the end of the subtitles file
            break;
          }
          subtitleIndex = int.parse(line);
          phase = Phase.timing;
          break;
        case Phase.timing:
          int arrowIndex = line.indexOf(arrow);
          String startTimeStr = line.substring(0, arrowIndex).trim();
          String endTimeStr = line.substring(arrowIndex + arrow.length).trim();
          startTimeDuration = TimeUtils.timeToDuration(startTimeStr);
          endTimeDuration = TimeUtils.timeToDuration(endTimeStr); //Not needed, but could be needed later?
          phase = Phase.content;
          break;
        case Phase.content:
          if(line.trim().isEmpty) {
            // debugPrint('***adding subtitle: $subtitleIndex / $startTimeDuration / $endTimeDuration / $content');
            final Subtitle subtitle = Subtitle(index: subtitleIndex, start: startTimeDuration!, end: endTimeDuration!, text: content);
            subtitles.add(subtitle);
            content = "";
            phase = Phase.lineIndex;
          } else {
            content = content.isEmpty ? line : content + Platform.lineTerminator + line;
          }
          break;
        default:
          return Subtitles([Subtitle(index: 1, start: const Duration(seconds: 0), end: const Duration(seconds: 10), text: 'Error loading subtitles')]);
      }
    }

    return Subtitles(subtitles);
  }
}