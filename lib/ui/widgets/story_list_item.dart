import 'package:app/ui/screens/view_story_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../schema/story.dart';
import '../../util/pref_utils.dart';

///A widget that shows a list item for a story.
class StoryListItem extends StatefulWidget {

  final Story story;
  final bool completed = true;

  const StoryListItem(this.story, {super.key});

  @override
  State<StoryListItem> createState() => _StoryListItemState();
}

class _StoryListItemState extends State<StoryListItem> {

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {

    Image imageWidget;

    if (widget.story.bannerImageURL.startsWith("http")) {
      imageWidget = Image(
        image: CachedNetworkImageProvider(widget.story.bannerImageURL),
        fit: BoxFit.fitWidth,
      );
    }
    else {
      imageWidget = Image.asset(widget.story.bannerImageURL, fit: BoxFit.fitWidth);
    }

    void showResetDialog() {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Reset story'),
          content: const Text('Are you sure you would like to reset the progress of this story?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {

                //Delete completion state:
                PreferenceUtils.resetStoryProgress(widget.story).then((value) {
                  setState(() {
                    Navigator.pop(context);
                  });
                },);

              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }

    void openStory() {
      Navigator.of(context).push(
        // implementing animation (slide from top to bottom)
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ViewStoryScreen(widget.story),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
            final offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      );//.then((value) { setState(() { }); },); //refresh the widget //TODO - WARNING: Is this needed? Creates a memory leak.
    }

    return FutureBuilder(
      future: _getPrefs(),
      builder: (context, snapshot) {
        bool storyCompleted = snapshot.data != null ? snapshot.data!.containsKey(PreferenceUtils.constructStoryCompletionKey(widget.story.id)) : false;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(),);
        }
        else {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading preferences"));
          }
          else {
            bool isPasswordProtected = widget.story.hasPassword();
            String? userPassword;
            return GestureDetector(
              onTap: () { // handle tap
                if(isPasswordProtected) {
                  // get password from user to allow access
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Private story'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('This is a private story. It will eventually become public. Until then, you need a password to access it.'),
                          TextFormField(
                            decoration: const InputDecoration(
                              icon: Icon(Icons.lock),
                              hintText: 'Password',
                              labelText: 'Password',
                            ),
                            onChanged: (String p) => userPassword = p,
                            obscureText: true,
                            enableSuggestions: false,
                            autocorrect: false,
                          )
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if(widget.story.checkPassword(userPassword)) {
                              openStory(); // password checked, so proceed to show story
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(userPassword == null || userPassword!.trim().isEmpty ? "Empty password" : "Wrong password"),
                              ));
                            }
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  openStory();
                }
              },
              onLongPress: () {
                if(isPasswordProtected) {
                  // show toast
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Cannot reset a private story"),
                  ));
                } else {
                  showResetDialog();
                }
              },
              child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(10.0), // Image border
                                child: AspectRatio(aspectRatio: 21/9, child: imageWidget)
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Visibility(visible: isPasswordProtected, child: const Icon(Icons.lock, size: 24.0, semanticLabel: 'Locked story - requires password.')),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(widget.story.title, style: Theme.of(context).textTheme.titleLarge)
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child:
                              storyCompleted ?
                                Row(
                                  children: [
                                    Expanded(child: Text(widget.story.getAuthors(), style: Theme.of(context).textTheme.labelMedium)),
                                    Container(width: 10),
                                    const Icon(Icons.check_circle, color: Colors.green)
                                  ],
                                )
                              :
                              Text(widget.story.getAuthors(), style: Theme.of(context).textTheme.labelMedium),
                        )
                      ],
                    ),
                ),
            );
          }
        }
      },
    );
  }
}
