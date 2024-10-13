import 'package:app/ui/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../util/pref_utils.dart';
import '../screens/nickname_screen.dart';
import '../screens/reset_uuid_screen.dart';
import 'buttons.dart';

///A widget that shows helpful information about the app.
class PrivacyWidget extends StatefulWidget {

  const PrivacyWidget({super.key});

  @override
  State<PrivacyWidget> createState() => _PrivacyWidgetState();
}

class _PrivacyWidgetState extends State<PrivacyWidget> {

  _openUrl(final Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  _openPrivacyPolicyUrl() {
    _openUrl(Uri.parse('https://prepared-project.eu/app#privacy'));
  }

  _editNickname() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const NicknameScreen(),
      ),
    ).then((_) => _updateFromPrefs() ); //refresh the widget
  }

  _resetUuid() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ResetUuidScreen(),
      ),
    ).then((_) => _updateFromPrefs() ); //refresh the widget
  }

  late String nickname = '';
  late String uuid = '';
  late bool showUnpublishedCaseStudies = false;

  @override
  void initState() {
    super.initState();
    _updateFromPrefs();
  }

  void _updateFromPrefs() async {
    SharedPreferences.getInstance().then((prefs) {
      nickname = prefs.getString(PreferenceUtils.keyNickname) ?? '';
      if(nickname.isEmpty) {
        nickname = PreferenceUtils.createRandomNickname();
        PreferenceUtils.saveNickname(nickname);
      }
      uuid = prefs.getString(PreferenceUtils.keyDeviceID) ?? '';
      showUnpublishedCaseStudies = prefs.getBool(PreferenceUtils.keyShowUnpublishedCaseStudies) ?? false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text('Your Privacy', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('This app and its use of personal data is governed by a Privacy Policy. You can view this policy on the project website.'),
                const SizedBox(height: 20),
                Center(
                  child: createButtonWithIcon('View Privacy Policy', const Icon(Icons.open_in_new, size: 16), _openPrivacyPolicyUrl, key: const Key('button-privacy-policy')),
                ),
                const SizedBox(height: 30, child: Divider()),
                const Text('Nickname', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('The app assigns you with a random nickname, for the purpose of displaying a name in the chats you participate to.'),
                const SizedBox(height: 10),
                const Text('You can personalise this nickname, or choose a new randomly generated one.'),
                const SizedBox(height: 10),
                RichText(
                    text: TextSpan(
                      text: 'Your current nickname is: ',
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: <TextSpan> [
                        TextSpan(text: nickname, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                      ]
                    )
                ),
                const SizedBox(height: 10),
                Center(child: createButtonWithoutIcon('Edit Nickname', _editNickname, key: const Key('button-edit-nickname'))),
                const SizedBox(height: 30, child: Divider()),
                const Text('Universally Unique Identifier (UUID)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('The app generates a unique identifier (in the form of a random number) so it can keep track of which users have answered each poll.'),
                const SizedBox(height: 10),
                const Text('You can optionally reset this UUID using the below button. However, note that this will also reset your poll selections.'),
                const SizedBox(height: 10),
                RichText(
                    text: TextSpan(
                        text: 'Your current UUID is: ',
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: <TextSpan> [
                          TextSpan(text: uuid, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                        ]
                    )
                ),
                const SizedBox(height: 10),
                Center(child: createButtonWithoutIcon('Reset UUID', _resetUuid, key: const Key('button-reset-uuid'))),
                const SizedBox(height: 30, child: Divider()),
                const Text('Preview Unpublished Case Studies', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Checking this option allows case study authors to preview unpublished case studies.'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Switch(
                      value: showUnpublishedCaseStudies,
                      onChanged: (bool value) {
                        // This is called when the user toggles the switch.
                        setState(() {
                          showUnpublishedCaseStudies = value;
                        });
                        // Save value in prefs
                        SharedPreferences.getInstance().then((prefs) {
                          prefs.setBool(PreferenceUtils.keyShowUnpublishedCaseStudies, showUnpublishedCaseStudies);
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                          showUnpublishedCaseStudies ? 'Showing unpublished items' : 'Not showing unpublished items',
                          style: TextStyle(fontStyle: FontStyle.italic, color: showUnpublishedCaseStudies ? Colors.red : Colors.black)
                      ),
                    ),
                  ]
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        )
    );
  }
}