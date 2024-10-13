import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/pref_utils.dart';
import '../../util/validation_utils.dart';
import '../styles/style.dart';

///A widget that allows the user to view and enter their nickname.
class NicknameWidget extends StatefulWidget {

  const NicknameWidget({super.key});

  @override
  State<NicknameWidget> createState() => _NicknameWidgetState();
}

class _NicknameWidgetState extends State<NicknameWidget> {

  late final TextEditingController _nicknameController = TextEditingController();
  late final FocusNode _nicknameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      String initialNickname = prefs.getString(PreferenceUtils.keyNickname) ?? PreferenceUtils.createRandomNickname();
      setState(() => _nicknameController.text = initialNickname);
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('The app assigns you with a random nickname, for the purpose of displaying a name in the chats you participate to.'),
              const SizedBox(height: 10),
              const Text('You can personalise this nickname, or choose a new randomly generated one.'),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
                color: Colors.grey[200],
                child: Form(
                  key: GlobalKey<FormState>(),
                  child: TextFormField(
                    controller: _nicknameController,
                    focusNode: _nicknameFocusNode,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                        labelText: "Edit nickname"
                    ),
                    validator: (value) => _validate(value),
                    onChanged: (value) => PreferenceUtils.saveNickname(value),
                    cursorHeight: cursorHeight,
                  ),
                ),
              ),
              const SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 50, child: Divider()),
                      SizedBox(width: 10),
                      Text('OR'),
                      SizedBox(width: 10),
                      SizedBox(width: 50, child: Divider()),
                    ],
                  )
              ),
              Center(child: _createButtonWithAnimatedIcon('Generate random nickname', const Icon(Icons.cached), _randomiseNickname, key: const Key('key-choose-random-nickname'))),
            ],
          ),
        ),
    );
  }

  _randomiseNickname() {
    String randomNickname = PreferenceUtils.createRandomNickname();
    setState(() => _nicknameController.text = randomNickname);
    PreferenceUtils.saveNickname(randomNickname);
  }

  String? _validate(final String? value) {
    if (value == null || value.isEmpty) {
      return "Please provide a name.";
    }
    if (value.length < 2) {
      return "A valid name must consist of 2 or more alphabetic characters.";
    }
    if (!ValidationUtils.isValidName(value)) {
      return "The name you provided is not valid. Please provide a valid name.";
    }
    return null;
  }
}
