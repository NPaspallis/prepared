import 'package:app/schema/component/multipoll_component.dart';
import 'package:app/schema/poll_option.dart';
import 'package:app/ui/styles/style.dart';
import 'package:app/ui/widgets/multipoll_results_widget.dart';
import 'package:app/util/file_utils.dart';
import 'package:app/util/pref_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/multipoll_entry.dart';
import '../../model/story_progress.dart';
import '../../util/device_utils.dart';
import '../../util/ui_utils.dart';

///A component that allows the user to participate in a poll.
class MultipollComponentView extends StatefulWidget {

  final String storyID;
  final MultipollComponent component;

  const MultipollComponentView(this.storyID, this.component, {super.key});

  @override
  State<MultipollComponentView> createState() => _MultipollComponentViewState();
}

class _MultipollComponentViewState extends State<MultipollComponentView> with TickerProviderStateMixin{

  Set<int> selectedPollValueIndices = {};
  late Widget webViewContentWidget;
  bool _feedbackVisible = false;
  bool _submitVisible = false;
  bool _checkboxesEnabled = true;
  bool _showResults = false;

  List<Checkbox> checkboxes = [];
  int numOfCheckedCheckboxes = 0;
  late Future<String> loadDataFuture;
  final ScrollController _scroller = ScrollController();
  late String deviceID;

  late List<int> userSelectionInPoll = []; //TODO - What is this??
  late Map<int, int> optionCounters = {};

  ///Retrieves the poll results from Firestore.
  Future<void> getPollResults() async {
        var querySnapshot = await FirebaseFirestore.instance.collection(
          "PollEntry")
          .where("pollID", isEqualTo: widget.component.id)
          .where("storyID", isEqualTo: widget.storyID)
          .get();

    //Initialize counters for all options:
    for (PollOption option in widget.component.options) {
      optionCounters[option.id] = 0;
    }

    for (final doc in querySnapshot.docs) {
      List<dynamic> dynamicList = doc.get("selectedOptionIndices");
      List<int> selectedOptionIndices = [];
      for (dynamic i in dynamicList) {
        selectedOptionIndices.add(i as int);
      }

      for (int optionIndex in selectedOptionIndices) {
        //Increment existing counter:
        int existingValue = optionCounters[optionIndex]!;
        existingValue++;
        optionCounters[optionIndex] = existingValue;
      }
    }
  }

  ///Checks whether this user has already answered this poll.
  Future<Set<int>> checkResponseToPoll() async {
    //Try to find if there are existing entries for this poll on Firestore:
    deviceID = (await DeviceUtils.getInstallationID())!;
    String pollEntryID = PreferenceUtils.constructPollEntryID(deviceID, widget.storyID, widget.component.id);
    var documentSnapshot = await FirebaseFirestore.instance.collection("PollEntry").doc(pollEntryID).get();
    if (documentSnapshot.exists) {
      List<dynamic> dynamicList = documentSnapshot.get("selectedOptionIndices");
      List<int> selectedOptionIndices = [];
      for (dynamic i in dynamicList) {
        selectedOptionIndices.add(i as int);
      }

      return selectedOptionIndices.toSet();
    }
    else {
      return {};
    }
  }

  ///Loads the necessary data and updates the state of the UI.
  Future<String> loadData() async {
    userSelectionInPoll = (await checkResponseToPoll()).toList();
    await getPollResults();
    //User has already selected previously, pick their previous answer automatically, and disable the controls:
    if (userSelectionInPoll.isNotEmpty) {
      setState(() {
        selectedPollValueIndices = userSelectionInPoll.toSet();
        _feedbackVisible = true;
        _submitVisible = false;
        _checkboxesEnabled = false;
        _showResults = true;
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

  onOptionSelection(PollOption option) {
    //Update the number of checked checkboxes:
    setState(() {

      if (selectedPollValueIndices.contains(option.id)) { //Uncheck
        selectedPollValueIndices.remove(option.id);
        numOfCheckedCheckboxes--;
      }
      else { //Check
        if (widget.component.maxSelections != null) {
          if (numOfCheckedCheckboxes < widget.component.maxSelections!) {
            numOfCheckedCheckboxes++;
            selectedPollValueIndices.add(option.id);
          }
          else {
            UIUtils.showErrorToast("You can only select up to ${widget.component.maxSelections} options.");
          }
        }
        else {
          numOfCheckedCheckboxes++;
          selectedPollValueIndices.add(option.id);
        }
      }

      debugPrint("maxSelections: ${widget.component.maxSelections}");
      debugPrint("numOfCheckedCheckboxes: $numOfCheckedCheckboxes");

      //Check if at least one option is selected and enable/disable submission:
      if (selectedPollValueIndices.isNotEmpty) {
        _submitVisible = true;
        UIUtils.showNeutralToast("When ready, scroll down to submit your answer.");
      }
    });
  }

  ///Constructs a poll option widget given an option and a response percentage.
  Widget constructPollOptionWidget(PollOption option, int numOfVotes) {

    Checkbox checkbox = Checkbox(
      value: selectedPollValueIndices.contains(option.id),
      onChanged: _checkboxesEnabled ? (checked) {
        onOptionSelection(option);
      } : null,
    );

    checkboxes.add(checkbox);

    Widget outputWidget;

    outputWidget = Container(
      color: Colors.transparent,
      child: ListTile(
        visualDensity: VisualDensity.compact,
        onTap: _checkboxesEnabled ? () {
          onOptionSelection(option);
        } : null,
        leading: checkbox,
        title: Text(option.title, style: const TextStyle(fontSize: 16)),
        subtitle: _showResults
            ? MultipollResultsWidget(numOfVotes)
            : null,
      ),
    );

    if (selectedPollValueIndices.contains(option.id)) {
      return Card(
        color: Colors.yellow[50],
        child: outputWidget,
      );
    }
    return outputWidget;
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
            for (PollOption option in widget.component.options) {
              optionsWidgets.add(constructPollOptionWidget(option, optionCounters[option.id]!));
            }

            return SingleChildScrollView(
              controller: _scroller,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 35, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Center(child: Text("Poll", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),

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
                      child: Text("You have already participated in this poll.", style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold),),
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

                    const SizedBox(height: 20,),

                    // Feedback
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: AnimatedOpacity(
                        opacity: _feedbackVisible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        // The green box must be a child of the AnimatedOpacity widget.
                        child: Visibility(
                          visible: _feedbackVisible,
                          child: Card(
                              color: Colors.yellow[100],
                              child: Padding(
                                padding: standardPadding,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Feedback:", style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 15,),
                                    Text(pickFeedback()),
                                  ],
                                ),
                              )
                          ),
                        ),
                      ),
                    ),

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
                                  _feedbackVisible = true;
                                  _submitVisible = false;
                                  _checkboxesEnabled = false;
                                  _showResults = true;
                                  // widget.finished = true;
                                  Provider.of<StoryProgress>(context, listen: false).setCompleted(widget.storyID, widget.component.getID(), true);
                                  _scrollDown();
                                },);
                              });
                              _createPollEntry(widget.storyID, selectedPollValueIndices);
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
  void _createPollEntry(String storyID, Set<int> selectedOptionIndices) {
    final MultipollEntry pollEntry = MultipollEntry(storyID, deviceID, selectedOptionIndices.toList(), widget.component.id);
    final String pollEntryID = PreferenceUtils.constructPollEntryID(deviceID, widget.storyID, widget.component.id);
    FirebaseFirestore.instance.collection("PollEntry").doc(pollEntryID).set(pollEntry.toJson())
    .then((value) {
      UIUtils.showSuccessToast("You have voted successfully");
    },)
    .catchError((error) {
      UIUtils.showErrorToast("Error while voting, please try again.");
      setState(() { //Re-enable controls to allow for re-submission.
        _checkboxesEnabled = true;
        _submitVisible = true;
      });
    });
  }

  ///Scrolls down to allow the user to view feedback.
  void _scrollDown() {
    _scroller.animateTo(
      1000,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  ///Picks feedback based on which type of feedback (general vs specific) is
  ///defined based on the option selected.
  String pickFeedback() {
    return widget.component.feedback;
  }

}