import 'package:app/util/device_utils.dart';
import 'package:app/util/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/pref_utils.dart';
import '../styles/style.dart';

///A widget that allows the user to view and enter their nickname.
class ResetUuidWidget extends StatefulWidget {

  const ResetUuidWidget({super.key});

  @override
  State<ResetUuidWidget> createState() => _ResetUuidWidgetState();
}

class _ResetUuidWidgetState extends State<ResetUuidWidget> {

  late String? uuid;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      setState(() => uuid = prefs.getString(PreferenceUtils.keyDeviceID));
    });
  }

  double _turns = 0.0;

  OutlinedButton _createButtonWithAnimatedIcon(final String label, final Icon icon, final VoidCallback onPressed, {required key}) {
    return OutlinedButton(
      key: key,
      onPressed: () {
        setState(() => _turns += 0.5);
        onPressed();
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.red)),
          const SizedBox(width: 5),
          AnimatedRotation(
            turns: _turns,
            duration: const Duration(milliseconds: 300),
            child: icon,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'The app generates a unique identifier (in the form of a random number) so it can keep track of which users have answered each poll.', //TODO - Internationalize
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium),
              const SizedBox(height: 10),
              Text(
                  'You can optionally reset this UUID using the below button. However, note that this will also reset your poll selections.', //TODO - Internationalize
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium),
              const SizedBox(height: 30, child: Divider(),),
              RichText(
                  text: TextSpan(
                      text: 'Your current UUID is: ', //TODO - Internationalize
                      style: Theme.of(context).textTheme.labelMedium,
                      children: <TextSpan> [
                        TextSpan(text: uuid, style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                      ]
                  )
              ),
              const SizedBox(height: 30, child: Divider()),
              const Text('Warning!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), //TODO - Internationalize
              const SizedBox(height: 10),
              const Text('If you proceed, then your progress in all case studies and your choices in every poll will be reset.', style: TextStyle(color: Colors.red)), //TODO - Internationalize
              const SizedBox(height: 20),
              Center(child: _createButtonWithAnimatedIcon('Confirm Reset UUID', const Icon(Icons.cached, color: Colors.red,), _resetUuid, key: const Key('key-confirm-reset-uuid'))), //TODO - Internationalize
              const SizedBox(height: 50, child: Divider()),
            ],
          )
        ),
    );
  }

  _resetUuid() {
    PreferenceUtils.resetAllStories().then((_) {
      DeviceUtils.resetInstallationID();
      Navigator.of(context).pop();
      UIUtils.showSuccessToast('UUID successfully reset'); //TODO - Internationalize
    },);
  }
}
