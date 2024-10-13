import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/pref_utils.dart';
import 'abstract_stack.dart';

class StoryBackstack {

  ///Clears the backstack of a story.
  static void clear(String storyID) {
    loadFromPrefs(storyID).then((value) {
      value!.clear();
      saveToPrefs(storyID, value);
    },);
  }

  //Saves a story's backstack to preferences.
  static Future<void> saveToPrefs(String storyID, AbstractStack<int> backstack) async {
    final String backstackKey = PreferenceUtils.constructStoryBackstackKey(storyID);
    if (kDebugMode) print("Saving stack contents:");
    if (kDebugMode) print("~ (bottom) ${backstack.asList()} (top) ~");
    var prefs = await SharedPreferences.getInstance();
    String? data = _serialize(backstack);
    prefs.setString(backstackKey, data);
  }

  //Loads a backstack from preferences.
  static Future<AbstractStack<int>?> loadFromPrefs(String storyID) async {
    final String backstackKey = PreferenceUtils.constructStoryBackstackKey(storyID);
    var prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(backstackKey)) {
      return null;
    }

    String? data = prefs.getString(backstackKey);
    if (data != null || data!.isEmpty) {
      return _deserialize(data);
    }
    return null;
  }

  //Serializes the backstack into a list of numbers, in CSV format.
  static String _serialize(AbstractStack<int> backstack) {
    String serialized = "";
    List<int> backstackAsList = backstack.asList();
    for (int i = 0; i < backstackAsList.length; i++) {
      int cIndex = backstackAsList[i];
      serialized += cIndex.toString();
      if (i < backstackAsList.length - 1) {
        serialized += ",";
      }
    }
    return serialized;
  }

  //Deserializes the backstack.
  static AbstractStack<int>? _deserialize(String data) {
    if (data.trim().isNotEmpty) {
      AbstractStack<int> stack = AbstractStack();
      List<String> parts = data.split(",");
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].trim().isNotEmpty) {
            int componentIndex = int.parse(parts[i]);
            stack.push(componentIndex);
        }
      }
      return stack;
    }
    return null;
  }

}