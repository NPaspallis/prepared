import 'package:app/app.dart';
import 'package:app/model/story_progress.dart';
import 'package:app/secrets.dart';
import 'package:app/util/speech_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///Initializes and runs the app.
SpeechState ttsState = SpeechState.stopped;

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Secrets.loadFromAssets(); // load secrets from assets folder
  runApp(
    ChangeNotifierProvider(
      create: (context) => StoryProgress(),
      child: const PreparedApp()
    )
  );
}