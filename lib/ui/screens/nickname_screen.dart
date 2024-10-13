import 'package:app/ui/widgets/nickname_widget.dart';
import 'package:flutter/material.dart';

//A screen that allows the user to change nickname settings.
class NicknameScreen extends StatelessWidget {

  const NicknameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Nickname'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: Colors.white,
        body: const NicknameWidget()
    );
  }
}
