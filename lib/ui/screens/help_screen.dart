import 'package:flutter/material.dart';

import '../widgets/help_widget.dart';

///A screen that shows help and other information about the app.
class HelpScreen extends StatelessWidget {

  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Help'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: Colors.white,
        body: const HelpWidget()
    );
  }
}
