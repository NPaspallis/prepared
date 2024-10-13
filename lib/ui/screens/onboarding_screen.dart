import 'package:app/ui/styles/style.dart';
import 'package:app/ui/widgets/html_viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/pref_utils.dart';
import 'info_screen.dart';

///A screen that allows the user to see information about the app and select their nickname.
///Shown only at the start of the app.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final List<Widget> _onboardingWidgets = const<Widget> [
    HtmlViewerWidget('assets/onboarding/eula.html'), // EULA
    HtmlViewerWidget('assets/onboarding/acceptable_use_policy.html'), // Acceptable Use Policy
    HtmlViewerWidget('assets/onboarding/privacy_policy.html'), // Privacy Policy
    HtmlViewerWidget('assets/onboarding/terms_and_conditions.html'), // Privacy Policy
  ];

  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to PREPARED App')),
      backgroundColor: Colors.white,
      body: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: PageView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  itemCount: _onboardingWidgets.length,
                  itemBuilder: (context, index) {
                    return _onboardingWidgets[index];
                  },
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                ),
              ),
              _getBottomNavigationView(),
            ],
          )),
    );
  }

  ///Saves data so that the onboarding process is not repeated.
  _onboardingCompleted() {
    // save in prefs onboarding completed
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(PreferenceUtils.keyOnboardingCompleted, true);
    });

    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            settings: const RouteSettings(name: '/about'),
            builder: (context) => const InfoScreen()
        )
    );
  }

  ///Constructs the bottom navigation view based on the component being viewed.
  Widget _getBottomNavigationView() {

    return SafeArea(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: _currentIndex == 0 ? null : _previous,
                  child: const Icon(Icons.skip_previous),
                ),
                Expanded(
                    child: Text("${_currentIndex+1} / ${_onboardingWidgets.length}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold))
                ),
                Container(width: 10),
                _currentIndex ==  _onboardingWidgets.length - 1?
                      OutlinedButton(
                        onPressed: _onboardingCompleted,
                        child: const Row(
                          children: [
                            Text("Accept", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            Icon(Icons.check)
                          ],
                        ),
                      ) :
                      OutlinedButton(
                        onPressed: _next,
                        child: const Icon(Icons.skip_next),
                      )
              ]
            )
        )
    );
  }

  void _previous() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn
    );
  }

  void _next() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeIn
    );
  }
}