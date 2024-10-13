import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../util/ui_utils.dart';
import '../styles/style.dart';

class UpdateAppWidget extends StatelessWidget {

  final String message;

  UpdateAppWidget({super.key, this.message = "The app is out of date."});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: standardPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 50,),
          const Gap(20),
          Text("$message Please update the app to continue.", textAlign: TextAlign.center,),
          const Gap(20),
          ElevatedButton(
            child: const Text("Update"),
            onPressed: () {
              if(Platform.isAndroid) {
                UIUtils.launchURL(
                    "https://play.google.com/store/apps/details?id=com.iclaim.prepared.prepared_app");
              } else if(Platform.isIOS) {
                UIUtils.launchURL(
                    "https://apps.apple.com/app/prepared-app/id6473009485");
              } else { // assume web even though this should never happen
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please refresh the web browser')));
              }
            },
          )
        ],
      ),
    );
  }
}
