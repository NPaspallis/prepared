import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Secrets {

  static const pathToSecretsAssetFile = 'assets/secrets/secrets.json'; // ensure this points to the correct file

  static Future<void> loadFromAssets() async {
    try {
      String jsonData = await rootBundle.loadString(pathToSecretsAssetFile);
      _secretValues =  jsonDecode(jsonData);
    } catch(e) {
      if (kDebugMode) {
        print("Error while initialising Secrets. Ensure you have defined the file '$pathToSecretsAssetFile'. Error: ${e.toString()}.");
      }
      _secretValues = {};
    }
  }

  static late Map _secretValues;

  static String getSecret(String key) {
    return _secretValues[key];
  }
}