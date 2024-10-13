import 'package:app/ui/screens/animation_screen.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'buttons.dart';

///A widget that shows app information.
class AboutWidget extends StatefulWidget {

  const AboutWidget({super.key});

  @override
  State<AboutWidget> createState() => _AboutWidgetState();
}

class _AboutWidgetState extends State<AboutWidget> {

  _openOurMissionUrl() {
    // open 'https://prepared-project.eu/our-mission/'
    _openUrl(Uri.parse('https://prepared-project.eu/our-mission'));
  }

  _viewProjectAnimationVideo() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const AnimationScreen();
      },
    ));
  }

  _openUrl(final Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                Image.asset("assets/images/logo_horizontal.jpg",
                    width: MediaQuery.of(context).size.width * 2 / 5),
                const SizedBox(height: 30, child: Divider()),
                Text(
                    'In times of crisis, accelerated research saves lives. PREPARED is designing a framework to accelerate research without sacrificing ethics and integrity.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall),
                const SizedBox(height: 10),
                createButtonWithIcon('Our Mission', const Icon(Icons.open_in_new, size: 16), _openOurMissionUrl, key: const Key('button-our-mission')),
                const SizedBox(height: 20, child: Divider()),
                Text(
                    'Want to see which project developed this app?',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall),
                const SizedBox(height: 10),
                Image.asset('assets/onboarding/animation-screenshot.png',
                      width: MediaQuery.of(context).size.width * 3 / 5),
                const SizedBox(height: 10),
                createButtonWithIcon('Watch video (3m55s)', const Icon(Icons.ondemand_video, size: 16), _viewProjectAnimationVideo, key: const Key('button-view-project-animation-video')),
                const SizedBox(height: 30, child: Divider()),
                Text(
                    "This app is developed by the PREPARED project consortium to supplement its educational material by providing an interactive tool for learning.",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall),
                const SizedBox(height: 40, child: Divider()),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Image.asset("assets/images/funded_by_the_eu_horizontal.jpg",
                      width: MediaQuery.of(context).size.width * 2 / 3),
                ),
                const SizedBox(height: 30, child: Divider()),
                FutureBuilder(
                  future: _getVersion(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Text(
                          'Version: ${snapshot.data!}',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall);
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  }
                ),
                const SizedBox(height: 40, child: Divider()),
              ],
            ),
          ),
        )
    );
  }

  Future<String> _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    return '$version-$buildNumber';
  }
}