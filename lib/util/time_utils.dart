import 'dart:math';

import 'package:flutter/cupertino.dart';

///A utility class that manages time conversions etc.
class TimeUtils {

  ///Converts time from a string in the format HH:MM:SS to seconds.
  static int timeToSeconds(String time) {
    List<String> parts = time.split(":");
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);

    int timeInSeconds = seconds;
    timeInSeconds += minutes * 60;
    timeInSeconds += hours * 3600;
    return timeInSeconds;
  }

  static Duration timeToDuration(String time) {
    int milliseconds = int.parse(time.substring(time.indexOf(',') + 1));
    List<String> parts = time.substring(0, time.indexOf(',')).split(":");
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);
    return Duration(hours: hours, minutes: minutes, seconds: seconds, milliseconds: milliseconds);
  }
}