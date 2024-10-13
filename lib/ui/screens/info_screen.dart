import 'package:app/ui/screens/view_stories_screen.dart';
import 'package:app/ui/styles/style.dart';
import 'package:app/ui/widgets/about_widget.dart';
import 'package:flutter/material.dart';

///A screen that shows information about the app.
class InfoScreen extends StatelessWidget {

  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('About PREPARED App'),
        ),
        backgroundColor: Colors.grey[200],
        body: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                child: const SingleChildScrollView(
                  child: AboutWidget(),
                )
              )
            ),
            const SizedBox(height: 5),
            getStartUsingTheAppButton(context),
            const SizedBox(height: 5),
          ],
        )
    );
  }

  Widget getStartUsingTheAppButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => Navigator
          .of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => const ViewStoriesScreen())),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Start using the app", style: TextStyle(fontWeight: FontWeight.w500, color: primaryColor)),
          SizedBox(width: 5),
          Icon(Icons.run_circle, color: primaryColor)
        ],
      ),
    );
  }
}