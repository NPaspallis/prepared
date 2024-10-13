import 'dart:convert';

import 'package:app/util/pref_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryProgress with ChangeNotifier {

  Map<String,Map<String,bool>> _storyToComponentToCompletedMap = {};
  // final Map<String, StackN<int>> _storyToComponentBackstack = {};

  @override
  String toString() {
    return _storyToComponentToCompletedMap.toString();
  }

  ///Sets the completion status of a component.
  void setCompleted(String storyId, String componentId, bool completed) {
    if(!_storyToComponentToCompletedMap.containsKey(storyId)) {
      _storyToComponentToCompletedMap[storyId] = {};
    }
    _storyToComponentToCompletedMap[storyId]![componentId] = completed;
    saveComponentCompletionToPrefs();
    notifyListeners();
  }

  ///Retrieves the completion status of a component.
  bool isCompleted(String storyId, String componentId) {
    loadComponentCompletionFromPrefs();
    if(!_storyToComponentToCompletedMap.containsKey(storyId)) {
      _storyToComponentToCompletedMap[storyId] = {};
    }
    final Map<String,bool> componentToCompletedMap = _storyToComponentToCompletedMap[storyId]!;
    if(!componentToCompletedMap.containsKey(componentId)) {
      componentToCompletedMap[componentId] = false;
    }
    return componentToCompletedMap[componentId]!;
  }

  ///Saves _storyToComponentToCompletedMap to preferences as a JSON object
  Future<void> saveComponentCompletionToPrefs() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    // print("~~~SAVING");
    String jsonString = json.encode(_storyToComponentToCompletedMap);
    // print(jsonString);
    sharedPreferences.setString(PreferenceUtils.keyCompletionMap, jsonString.toString());
  }

  ///Loads _storyToComponentToCompletedMap from preferences
  Future<void> loadComponentCompletionFromPrefs() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey(PreferenceUtils.keyCompletionMap)) {
      String? jsonString = sharedPreferences.getString(PreferenceUtils.keyCompletionMap);
      // print("~~~LOADING");
      Map<String, dynamic> map = json.decode(jsonString!);
      Map<String, Map<String, bool>> finalMap = {};
      //construct outer map (story ID to components map):
      map.forEach((key, value) {
        Map<String, bool> innerMap = {};
        Map valuesMap = value as Map<String, dynamic>;
        //inner map (components to completion values) manually:
        valuesMap.forEach((key, value) {
          bool completed = value as bool;
          innerMap[key] = completed;
        });
        finalMap[key] = innerMap;
      });
      // print(finalMap);
      _storyToComponentToCompletedMap = finalMap;
    }
  }

  ///Saves _storyToComponentToCompletedMap to preferences as a JSON object
  static Future<void> saveComponentCompletionManually(Map<String, Map<String, bool>> map) async {
    var sharedPreferences = await SharedPreferences.getInstance();
    // print("~~~SAVING");
    String jsonString = json.encode(map);
    // print(jsonString);
    sharedPreferences.setString(PreferenceUtils.keyCompletionMap, jsonString.toString());
  }

  ///Loads _storyToComponentToCompletedMap from preferences
  static Future<Map<String, Map<String, bool>>> loadComponentCompletionManually() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey(PreferenceUtils.keyCompletionMap)) {
      String? jsonString = sharedPreferences.getString(PreferenceUtils.keyCompletionMap);
      // print("~~~LOADING");
      Map<String, dynamic> map = json.decode(jsonString!);
      Map<String, Map<String, bool>> finalMap = {};
      //construct outer map (story ID to components map):
      map.forEach((key, value) {
        Map<String, bool> innerMap = {};
        Map valuesMap = value as Map<String, dynamic>;
        //inner map (components to completion values) manually:
        valuesMap.forEach((key, value) {
          bool completed = value as bool;
          innerMap[key] = completed;
        });
        finalMap[key] = innerMap;
      });
      // print(finalMap);
      return finalMap;
    }
    else {
      return {};
    }
  }

  ///Adds a component to a story's backstack.
  // void pushComponentToBackstack(String storyID, int componentIndex) {
  //   if (_storyToComponentBackstack[storyID] == null) {
  //     _storyToComponentBackstack[storyID] = StackN();
  //   }
  //   _storyToComponentBackstack[storyID]?.push(componentIndex);
  // }

  ///Removes a component from a story's backstack and returns its index.
  // int? popComponentFromBackstack(String storyID) {
  //   if (_storyToComponentBackstack[storyID] == null) {
  //     return null;
  //   }
  //
  //   if (_storyToComponentBackstack[storyID]!.isEmpty()) {
  //     return null;
  //   }
  //
  //   return _storyToComponentBackstack[storyID]!.pop();
  // }

  ///Peeks on the backstack without changing its contents.
  // int? peekBackstack(String storyID) {
  //   if (_storyToComponentBackstack[storyID] == null) {
  //     return null;
  //   }
  //
  //   if (_storyToComponentBackstack[storyID]!.isEmpty()) {
  //     return null;
  //   }
  //
  //   return _storyToComponentBackstack[storyID]!.peek();
  // }



  //Retrieves the backstack for a story.
  // StackN<int>? getBackstack(String storyID) {
  //   if (_storyToComponentBackstack[storyID] == null) {
  //     _storyToComponentBackstack[storyID] = StackN();
  //   }
  //   return _storyToComponentBackstack[storyID];
  // }



}