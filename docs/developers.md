<img src="programmer-with-laptops.png" alt="From https://publicdomainvectors.org/" style="width:150px;" align="left"/>

# Developers' Guide for building an app with the _PREPARED_ framework for educational apps

_For app developers_

## Overview

The framework is used to develop apps that targets the two most popular and common smartphone
platforms: Android and iOS.
The design of the App assumes no specialized skills by the users, besides familiarity with
installing and operating common mobile apps in either of the two targeted platforms.

## Project structure

* `\lib` contains Flutter source code.
* `\assets` contains various assets (such as images, fonts, etc) used in the app.
* `pubspec.yaml` contains project configuration and dependencies.
* `README.md` (this file) contains information about the Flutter project and its build process.

### Secret files for Android Apps

If you wish to build and release Android apps, consider the following:
* Add a file under `\android` with the name `key.properties`. This must include the following properties:
    * `storePassword`
    * `keyPassword`
    * `keyAlias`
    * `storeFile`
* For using Firebase, you need to create a new account, generate the `google-services.json` file and store it under `/android/app`

## Build

To build the project install the Flutter SDK, set up your environment, and run:
* ``flutter pub get``
* ``flutter pub run flutter_launcher_icons``
* ``flutter run``

To run with a _release profile_, use:
* ``flutter run --release``

## Prepare

Make sure the stories do not include unsupported characters, like '’'.

### Android
* If you are using Firebase, make sure to store `google-services.json` under `android/app`
* To release an app (build the bundle) you will need to define a `android/key.properties` file containing the following values:
  * storePassword
  * keyPassword
  * keyAlias
  * storeFile

## Release

Clean the project
* Make sure you updated the version number in ``pubspec.yaml``
* Make sure you have pointed the main file to the cloud: ``FileUtils.loadTextFile(cloudStoriesUrl)`` in file ``file_utils.dart``.
* ``flutter clean``
* Do your testing
  * Make sure the case studies work ok
* Create a label on Github to mark the version you are releasing

### Android

Build the bundle for Android release:
* ``flutter build appbundle``
  * The release bundle for your app is created at ``[project]/build/app/outputs/bundle/release/app-release.aab``.
* Optionally, create the _native debug symbols for app bundle_ (see [how](https://stackoverflow.com/a/68778908))
  * Goto ``[YOUR_PROJECT]\build\app\intermediates\merged_native_libs\release\out\lib``
  * Create a ``.zip`` file containing the 3 folders: ``arm64-v8a``, ``armeabi-v7a``, ``x86_64``.
* Follow the [official instructions](https://docs.flutter.dev/deployment/android) to upload the bundle on Google Developer Console

Alternatively, you can run the release version on the emulator as follows:
* ``flutter run --release``
  * Optionally, add the ``--verbose`` parameter to display the full output as a log

### iOS

Build the ipa for iOS release
* ``flutter build ipa``
  * The release ipa for your app is created at ``[project]/build/ios/ipa/``
* See the [Release an iOS app with Flutter in 7 steps](https://www.youtube.com/watch?v=iE2bpP56QKc&t=591s) video.
* Alternatively, in XCode use `Product`, `Archive`.
  * You can ignore a warning related to `Missing Push Notification Entitlement` - it is related to Flutter using the delegate [Github post](https://stackoverflow.com/a/55167613)

## Creating UML

Using the [dcdg](https://pub.dev/packages/dcdg) plugin
* ``dcdg --include '^Component^' --exclude '^flutter,^View,ComponentType,ComponentChoice' -o p1.puml``