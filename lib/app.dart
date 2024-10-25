import 'package:app/ui/screens/start_screen_selector.dart';
import 'package:app/ui/styles/style.dart';
import 'package:app/util/device_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///The app widget.
class PreparedApp extends StatefulWidget {

  static int appSchemaVersion = 1;
  static int onlineDataSchemaVersion = -1;

  const PreparedApp({super.key});

  @override
  State<PreparedApp> createState() => _PreparedAppState();
}

class _PreparedAppState extends State<PreparedApp> {

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((value) {
      FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false); //Don't use offline data
    });

    //Generate a new device ID if it does not exist:
    DeviceUtils.generateInstallationID();
  }

  @override
  Widget build(BuildContext context) {

    //Force portrait mode:
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);

    // create the app
    return MaterialApp(
      title: 'PREPARED App',
      theme: ThemeData(
          primarySwatch: Colors.teal,
          splashColor: Colors.lime,
          fontFamily: 'Open Sans',
          textTheme: const TextTheme(
            bodySmall: TextStyle(fontSize: normalTextSmall),
            bodyMedium: TextStyle(fontSize: normalTextBig),
            bodyLarge: TextStyle(fontSize: 20),
          ),
          useMaterial3: true,
          outlinedButtonTheme: const OutlinedButtonThemeData(style: ButtonStyle())),
      home: const StartScreenSelector(),
      // debugShowCheckedModeBanner: false,
    );
  }
}