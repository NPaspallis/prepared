import 'package:app/ui/screens/help_screen.dart';
import 'package:app/ui/screens/privacy_screen.dart';
import 'package:app/ui/widgets/update_app_widget.dart';
import 'package:app/util/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../app.dart';
import '../../schema/story.dart';
import '../../util/file_utils.dart';
import '../widgets/story_list_item.dart';
import 'about_screen.dart';

//A screen that allows the user to view a list of available stories.
class ViewStoriesScreen extends StatefulWidget {

  //Needed as reference to stories to delete their progress later.
  //(mostly to avoid reloading them from file)
  static List<Story?> stories = [];

  const ViewStoriesScreen({super.key});

  @override
  State<ViewStoriesScreen> createState() => _ViewStoriesScreenState();
}

class _ViewStoriesScreenState extends State<ViewStoriesScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);

    return FutureBuilder(
      future: InternetConnection().hasInternetAccess,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
              body: Center(
                  child: CircularProgressIndicator(),
              ),
          );
        }
        else {
          if (!snapshot.data!) {
            return UIUtils.noInternetOverlay(() {
              setState(() { });
            });
          }
          else {
            return Scaffold(
                appBar: AppBar(
                  title: const Text('PREPARED App'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      tooltip: 'About the App',
                      onPressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(
                                settings: const RouteSettings(name: '/about'),
                                builder: (context) => const AboutScreen()
                            )
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.privacy_tip_outlined),
                      tooltip: 'Privacy',
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return const PrivacyScreen();
                          },
                        )).then((value) {
                          //When back from privacy screen, reload the screen to show the updated list of stories
                          setState(() { });
                        },);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.help_outline),
                      tooltip: 'Help',
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return const HelpScreen();
                          },
                        ));
                      },
                    ),
                  ],
                ),
                body: FutureBuilder(
                  future: FileUtils.loadStories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    else {
                      if (snapshot.data != null && !snapshot.hasError) {
                        ViewStoriesScreen.stories = snapshot.data!;
                        return ListView(
                          children: snapshot.data!.map((e) {
                            return StoryListItem(e);
                          }).toList(),
                        );
                      }
                      else {
                        Widget errorWidget;
                        if (PreparedApp.appSchemaVersion != PreparedApp.onlineDataSchemaVersion) {
                          errorWidget = UpdateAppWidget();
                        }
                        else {
                          errorWidget = const Center(child: Text("Error reading stories.json"));
                        }
                        return errorWidget;
                      }
                    }
                  },
                )
            );
          }
        }
      },
    );

  }
}