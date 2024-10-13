import 'package:flutter/material.dart';

import '../widgets/reset_uuid_widget.dart';

//A screen that allows the user to change app settings.
class ResetUuidScreen extends StatelessWidget {

  const ResetUuidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Reset UUID'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: Colors.white,
        body: const ResetUuidWidget()
    );
  }
}
