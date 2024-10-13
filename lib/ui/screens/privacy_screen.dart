import 'package:flutter/material.dart';

import '../widgets/privacy_widget.dart';

///A screen that shows help and other information about the app.
class PrivacyScreen extends StatelessWidget {

  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Privacy'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: Colors.white,
        body: const PrivacyWidget()
    );
  }
}