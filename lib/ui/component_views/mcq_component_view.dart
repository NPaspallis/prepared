import 'package:app/model/poll_entry.dart';
import 'package:app/schema/component/mcq_component.dart';
import 'package:app/schema/mcq_option.dart';
import 'package:app/ui/styles/style.dart';
import 'package:app/util/file_utils.dart';
import 'package:app/util/pref_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../../model/story_progress.dart';
import '../../util/device_utils.dart';
import '../../util/ui_utils.dart';

///A component that allows the user to answer MCQ questions.
class MCQComponentView extends StatefulWidget {

  final String storyID;
  final MCQComponent component;

  const MCQComponentView(this.storyID, this.component, {super.key});

  @override
  State<MCQComponentView> createState() => _MCQComponentViewState();
}

class _MCQComponentViewState extends State<MCQComponentView> with TickerProviderStateMixin{

  int selectedAnswerValueIndex = -1;
  late Widget webViewContentWidget;
  bool _feedbackVisible = false;
  bool _submitVisible = false;
  bool _radioButtonsEnabled = true;
  bool _showResults = false;

  List<Radio<int>> radioButtons = [];
  late Future<String> loadDataFuture;
  final ScrollController _scroller = ScrollController();
  late String deviceID;

  late int userSelection = -1;
  late Map<int, int> optionCounters = {};

  ///Checks whether this user has already answered this poll.
  Future<int> checkResponseToPoll() async {
    //Try to find if there are existing entries for this poll on Firestore:
    deviceID = (await DeviceUtils.getInstallationID())!;
    String mcqEntryID = PreferenceUtils.constructPollEntryID(deviceID, widget.storyID, widget.component.id);
    var documentSnapshot = await FirebaseFirestore.instance.collection("MCQEntry").doc(mcqEntryID).get();
    if (documentSnapshot.exists) {
      return documentSnapshot.get("selectedOptionIndex");
    }
    else {
      return -1;
    }
  }

  ///Loads the necessary data and updates the state of the UI.
  Future<String> loadData() async {
    userSelection = await checkResponseToPoll();
    //User has already selected previously, pick their previous answer automatically, and disable the controls:
    if (userSelection != -1) {
      setState(() {
        selectedAnswerValueIndex = userSelection;
        _feedbackVisible = true;
        _submitVisible = false;
        _radioButtonsEnabled = false;
        _showResults = true;
        // widget.finished = true;
        Provider.of<StoryProgress>(context, listen: false).setCompleted(
            widget.storyID, widget.component.getID(), true);
      });
    }
    return await FileUtils.loadHTMLContentForVideoComponent(
        widget.component.content);
  }

  @override
  void initState() {
    loadDataFuture = loadData();
    super.initState();
  }

  ///Constructs an answer option widget
  Widget constructMCQOptionWidget(MCQOption option) {

    Radio<int> radio = Radio<int>(
      key: Key("mcqOption-${option.id}"),
      value: option.id,
      groupValue: selectedAnswerValueIndex,
      onChanged: _radioButtonsEnabled ? (value) {
        setState(() {
          selectedAnswerValueIndex = option.id;
          _submitVisible = true;
          _scrollDown();
        });
      } : null,
    );
    radioButtons.add(radio);

    Widget outputWidget;

    if (selectedAnswerValueIndex != option.id) {
      outputWidget = Container(
      color: _showResults && selectedAnswerValueIndex == option.id ? Colors.yellow.shade300 : Colors.transparent,
      child: ListTile(
        visualDensity: VisualDensity.compact,
        onTap: _radioButtonsEnabled ? () {
          setState(() {
            selectedAnswerValueIndex = option.id;
            _submitVisible = true;
            _scrollDown();
          });
        } : null,
        leading: radio,
        title: Text(option.title, style: const TextStyle(fontSize: 16)),
        subtitle: _feedbackVisible && option.feedback.isNotEmpty ?  createFeedbackSubtitle(option) : null,
      ),
    );
    } else {
      outputWidget = Card(
      color: _showResults && selectedAnswerValueIndex == option.id ? Colors.yellow[50] : Colors.white,
      child: ListTile(
        visualDensity: VisualDensity.compact,
        onTap: _radioButtonsEnabled ? () {
          setState(() {
            selectedAnswerValueIndex = option.id;
            _submitVisible = true;
            _scrollDown();
          });
        } : null,
        leading: radio,
        title: Text(option.title, style: const TextStyle(fontSize: 16)),
        subtitle: _feedbackVisible && option.feedback.isNotEmpty ?  createFeedbackSubtitle(option) : null,
      ),
    );
    }
    return outputWidget;
  }

  Widget createFeedbackSubtitle(MCQOption option) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: const BoxDecoration(
          border: Border.symmetric(horizontal: BorderSide(
              width: 1,
              color: Colors.grey
          ))
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          option.correct ? const Icon(Icons.check_circle, color: Colors.green,) : const Icon(Icons.dangerous_rounded, color: Colors.red,),
          const Gap(10),
          Flexible(child: Text(option.feedback, style: const TextStyle(fontSize: 14),)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> optionsWidgets = [];

    return FutureBuilder(
      future: loadDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        else {
          if (snapshot.hasError || snapshot.data == null) {
            //Error Screen
            debugPrintStack(stackTrace: snapshot.stackTrace);
            return buildErrorScreen();
          } else {

            //Initialize the option widgets to correct progresses:
            for (MCQOption option in widget.component.options) {
              optionsWidgets.add(constructMCQOptionWidget(option));
            }

            return SingleChildScrollView(
              controller: _scroller,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 35, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    const Center(child: Text("Multiple choice question", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),

                    const SizedBox(height: 10,),

                    Text(widget.component.prompt),

                    const SizedBox(height: 10,),

                    Card(
                      color: Colors.lime.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Question", style: Theme.of(context).textTheme.titleLarge),
                                const CircleAvatar(
                                  backgroundColor: Colors.teal,
                                  child: Icon(Icons.question_mark_rounded, color: Colors.white,),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Text(widget.component.content),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10,),

                    const Divider(),

                    _showResults ? const SizedBox(height: 20,) : Container(),

                    _showResults ? Center(
                      child: Text("You have already answered this question", style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold),),
                    ) : Container(),

                    _showResults ? const SizedBox(height: 10,) : Container(),

                    //Options:
                    Container(
                        padding: standardPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: optionsWidgets,
                        )
                    ),

                    //Generic feedback:

                    widget.component.feedback.isNotEmpty ?
                    Card(
                      color: Colors.yellow.shade100,
                      child: Padding(
                        padding: standardPadding,
                        child: Text("Feedback:\n\n ${widget.component.feedback}"),
                      ),
                    )
                    : Container(),

                    //Submit button:
                    AnimatedOpacity(
                      opacity: _submitVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      // The green box must be a child of the AnimatedOpacity widget.
                      child: Visibility(
                        visible: _submitVisible,

                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40),
                              backgroundColor: Colors.lime.shade50,
                              foregroundColor: Colors.green.shade800,
                              textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              elevation: 3
                            ),
                            child: Row(
                              children: [
                                const Spacer(),
                                Text("Submit".toUpperCase(), style: const TextStyle(fontSize: normalTextSmall),),
                                const Spacer(),
                                const Icon(Icons.check),
                              ],
                            ),
                            onPressed: () {
                              setState(() {
                                loadData().then((value) {
                                  if (selectedAnswerValueIndex != -1) {
                                    _feedbackVisible = true;
                                    _submitVisible = false;
                                    _radioButtonsEnabled = false;
                                    _showResults = true;
                                    // widget.finished = true;
                                    if(context.mounted) {
                                      Provider.of<StoryProgress>(
                                          context, listen: false).setCompleted(
                                          widget.storyID,
                                          widget.component.getID(), true);
                                    }
                                  }
                                  _scrollDown();
                                },);
                              });
                              _createPollEntry(widget.storyID, selectedAnswerValueIndex);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
      },
    );
  }

  ///Builds the error (disconnected) screen.
  Widget buildErrorScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [

          const SizedBox(height: 20,),

          const Icon(Icons.signal_wifi_connected_no_internet_4, color: Colors.red, size: 50,),

          const SizedBox(height: 20,),

          const Text("This section could not be loaded.", textAlign: TextAlign.center),

          const SizedBox(height: 20,),

          const Text("Please make sure you have an internet connection", textAlign: TextAlign.center),

          const SizedBox(height: 20,),

          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text("Try again"),
            onPressed: () {
              setState(() {
                loadDataFuture = loadData();
              });
            },
          ),

        ],
      ),
    );
  }

  ///Creates a new poll option entry on Firestore, given its option index.
  void _createPollEntry(String storyID, int selectedOptionIndex) {
    final PollEntry pollEntry = PollEntry(storyID, deviceID, selectedOptionIndex, widget.component.id);
    final String pollEntryID = PreferenceUtils.constructPollEntryID(deviceID, widget.storyID, widget.component.id);
    FirebaseFirestore.instance.collection("MCQEntry").doc(pollEntryID).set(pollEntry.toJson())
    .then((value) {
      UIUtils.showSuccessToast("Your response was submitted");
    },)
    .catchError((error) {
      UIUtils.showErrorToast("Error while submitting answer, please try again.");
      setState(() { //Re-enable controls to allow for re-submission.
        _radioButtonsEnabled = true;
        _submitVisible = true;
      });
    });
  }

  ///Scrolls down to allow the user to view feedback.
  void _scrollDown() {
    _scroller.animateTo(
      1,
      duration: const Duration(milliseconds: 100),
      curve: Curves.fastOutSlowIn,
    ) // a small hack to allow smooth scrolling to bottom
        .then((value) => _scroller.animateTo(_scroller.position.maxScrollExtent, duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn));
  }

}
