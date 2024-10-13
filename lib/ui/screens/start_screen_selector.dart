import 'package:app/ui/screens/onboarding_screen.dart';
import 'package:app/ui/screens/view_stories_screen.dart';
import 'package:app/util/pref_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

///A utility class that enables the user to view either the onboarding process if this
///is their first time in the app, or the list of stories.
class StartScreenSelector extends StatefulWidget {

  const StartScreenSelector({super.key});

  @override
  State<StartScreenSelector> createState() => _StartScreenSelectorState();
}

class _StartScreenSelectorState extends State<StartScreenSelector> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data!.getBool(PreferenceUtils.keyOnboardingCompleted) ?? false) {
              return const ViewStoriesScreen();
            } else {
              return const OnboardingScreen();
            }
          }
          else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        }
    );
  }
}
