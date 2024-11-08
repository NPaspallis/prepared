import 'package:app/ui/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

///A utility class that contains various functions related to the UI.
class UIUtils {

  ///Shows an error toast.
  static void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.redAccent,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
    );
  }

  ///Shows a success toast.
  static void showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
    );
  }

  ///Shows a neutral message toast.
  static void showNeutralToast(String message, {ToastGravity gravity = ToastGravity.CENTER}) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.grey.shade700,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: 3,
    );
  }

  static Widget noInternetOverlay(Function onRetryCallback) {
    return Scaffold(
      body: Padding(
        padding: standardPadding,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.signal_wifi_connected_no_internet_4, color: Colors.red, size: 50,),
              const Gap(20),
              const Text("No internet", style: TextStyle(fontSize: 26),),
              const Gap(20),
              const Text("Please make sure you have an internet connection.", textAlign: TextAlign.center),
              const Gap(20),
              ElevatedButton(
                child: const Text("Retry"),
                onPressed: () {
                  onRetryCallback();
                },
              )
            ],
          ),
        )
      ),
    );
  }

  static launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}