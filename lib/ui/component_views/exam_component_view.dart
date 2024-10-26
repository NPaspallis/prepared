import 'package:app/model/story_progress.dart';
import 'package:app/schema/exam/exam_question.dart';
import 'package:app/schema/exam/exam_answer.dart';
import 'package:app/schema/component/exam_component.dart';
import 'package:app/ui/component_views/labeled_checkbox.dart';
import 'package:app/ui/component_views/labeled_radio.dart';
import 'package:app/ui/styles/style.dart';
import 'package:app/ui/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/util/pref_utils.dart';


/// A component that allows the user to take a multiple choice exam with a min
/// requirement of correct answers to pass.
class ExamComponentView extends StatefulWidget {

  final String storyId;
  final ExamComponent component;

  const ExamComponentView(this.storyId, this.component, {super.key});

  @override
  State<ExamComponentView> createState() => _ExamComponentViewState();
}

class _ExamComponentViewState extends State<ExamComponentView> {

  late int _currentQuestionIndex = 0;

  bool _alreadyPassed = false;

  String _getKeyCurrentQuestionIndex() {
    return '${PreferenceUtils.keyCurrentQuestionIndex}-${widget.storyId}-${widget.component.id}';
  }

  String _getKeyCurrentQuestionAnswerIndex(int answerId) {
    return '${PreferenceUtils.keyCurrentQuestionAnswerIndex}-${widget.storyId}-${widget.component.id}-$answerId';
  }

  late String content;
  late List<ExamQuestion> examQuestions;
  late List<List<ExamAnswer>> examQuestionsToAnswers;
  late int numOfExamQuestions;
  late double minPercentageToPass;
  late Map<int,List<String>> selectedAnswers; // selected by the user already

  double _percentagePassed = 0.0;

  @override
  void initState() {
    super.initState();
    content = widget.component.content;
    examQuestions = widget.component.questions;
    numOfExamQuestions = examQuestions.length;
    examQuestionsToAnswers = List.filled(numOfExamQuestions, []);
    selectedAnswers = <int,List<String>>{};
    for(int i = 0; i < numOfExamQuestions; i++) {
      examQuestionsToAnswers[i] = examQuestions[i].examAnswers;
      if(examQuestions[i].shuffledAnswers) {
        examQuestions[i].examAnswers.shuffle();
      }
      selectedAnswers[i] = [];
    }
    minPercentageToPass = widget.component.minPercentageToPass;

    _alreadyPassed = Provider.of<StoryProgress>(context, listen: false).isCompleted(widget.storyId, widget.component.id);

    // restore current index
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _currentQuestionIndex = prefs.getInt(_getKeyCurrentQuestionIndex()) ?? 0;
        for(int i = 0; i < numOfExamQuestions; i++) {
          selectedAnswers[i] = prefs.getStringList(_getKeyCurrentQuestionAnswerIndex(i)) ?? [];
        }
        _checkIfPassed();
      });
    });
  }

  @override
  void dispose() {
    SharedPreferences.getInstance().then((prefs) {
      // save current question index
      prefs.setInt(_getKeyCurrentQuestionIndex(), _currentQuestionIndex);

      // save selected answers
      for(int i = 0; i < selectedAnswers.length; i++) {
        prefs.setStringList(_getKeyCurrentQuestionAnswerIndex(i), selectedAnswers[i]!);
      }
    });
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    List<Widget> questionWidgets = [];

    //Show all messages up to the current message index.
    for(int i = 0; i <= _currentQuestionIndex && i < numOfExamQuestions; i++) {
      bool visibleResult = i < _currentQuestionIndex;
      bool enabled = i == _currentQuestionIndex;
      questionWidgets.addAll(getQuestionWidget(i, visibleResult, enabled));
    }
    _scrollToEnd();

    return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Text(widget.component.content)
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.school, color: primaryColor, size: 32),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text('Achieve at least ${minPercentageToPass.toStringAsFixed(1)}% to pass.',
                        style: Theme.of(context).textTheme.bodySmall))
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Colors.grey),

                Expanded(
                  child: ListView(
                      controller: _scrollController,
                      children: questionWidgets
                  )
                ),

                const Divider(height: 1, color: Colors.grey),
                const SizedBox(height: 10),
                chooseWidgetForNextStep()
              ]
          )
    );
  }

  Widget chooseWidgetForNextStep() {
    if(_currentQuestionIndex < numOfExamQuestions) {
      return createButtonWithIcon(
        'Confirm and Proceed',
        const Icon(Icons.chevron_right_outlined),
        _currentQuestionIndex < numOfExamQuestions && selectedAnswers[_currentQuestionIndex]!.isNotEmpty ? () => _confirmAndProceed() : null,
        key: const Key('button-confirm-and-proceed'),
      );
    }
    else {
      if(_alreadyPassed) {
        return RichText(
          text: TextSpan(
            text: '',
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(text: 'Well done! ', style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold)),
              TextSpan(text: 'Your score is ${_percentagePassed.toStringAsFixed(1)}%, which meets or exceeds the required threshold of ${minPercentageToPass.toStringAsFixed(1)}%. ', style: Theme.of(context).textTheme.bodySmall),
              TextSpan(text: 'You can proceed to the next page.', style: Theme.of(context).textTheme.bodySmall)
            ],
          ),
        );
      } else {
        return Column(
          children: [
            Text('Your score is ${_percentagePassed.toStringAsFixed(1)}%, which is below the required threshold of $minPercentageToPass%.',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.red)),
            const SizedBox(height: 10),
            createButtonWithIcon(
              'Try again',
              const Icon(Icons.refresh),
              _tryAgain,
              key: const Key('button-try-again'),
            )
          ],
        );
      }
    }
  }

  void _tryAgain() {
    // reset everything
    setState(() {
      _currentQuestionIndex = 0;
      for(int i = 0; i < selectedAnswers.length; i++) {
        selectedAnswers[i] = [];
      }
    });
  }

  LabeledRadio getLabeledRadio(int questionIndex, ExamAnswer examAnswer, final bool visibleResult, final bool enabled, final bool emphasized) {
    final String groupValue = selectedAnswers[questionIndex]!.isEmpty ? '' : selectedAnswers[questionIndex]![0];
    return LabeledRadio(
      label: examAnswer.text,
      padding: const EdgeInsets.fromLTRB(0.0, 5.0, 5.0, 5.0),
      value: examAnswer.text,
      groupValue: groupValue,
      onChanged: (String newValue) {
        setState(() {
          selectedAnswers[questionIndex]!.clear();
          selectedAnswers[questionIndex]!.add(examAnswer.text);
        });
      },
      correct: examAnswer.correct,
      visibleResult: visibleResult,
      enabled: enabled,
      emphasized: emphasized,
    );
  }

  LabeledCheckbox getLabeledCheckbox(int questionIndex, ExamAnswer examAnswer, final bool visibleResult, final bool enabled, final bool emphasized) {

    return LabeledCheckbox(
      label: examAnswer.text,
        padding: const EdgeInsets.fromLTRB(0.0, 5.0, 5.0, 5.0),
      checked: selectedAnswers[questionIndex]!.contains(examAnswer.text),
      onChanged: (bool checked) {
        setState(() {
          if(checked) {
            selectedAnswers[questionIndex]!.add(examAnswer.text);
          } else { // unchecked
            selectedAnswers[questionIndex]!.remove(examAnswer.text);
          }
        });
      },
      correct: examAnswer.correct,
      visibleResult: visibleResult,
      enabled: enabled,
      emphasized: emphasized
    );
  }

  List<Widget> getQuestionWidget(final int questionIndex, final bool visibleResult, final bool enabled) {

    final ExamQuestion examQuestion = examQuestions[questionIndex];

    // produce a labeledRadio for each possible answer
    List<ExamAnswer> selectedExamAnswers = examQuestionsToAnswers[questionIndex];
    int countCorrect = 0;
    for (ExamAnswer examAnswer in selectedExamAnswers) {
      countCorrect += examAnswer.correct ? 1 : 0;
    }

    List<Widget> labeledAnswers = [];
    for(int i = 0; i < selectedExamAnswers.length; i++) { // populate answers with radio or checkboxes as needed
      ExamAnswer examAnswer = selectedExamAnswers[i];
      if(countCorrect == 1) { // use radio buttons
        labeledAnswers.add(getLabeledRadio(questionIndex, examAnswer, visibleResult, enabled, i.isOdd));
      } else { // use checkboxes
        labeledAnswers.add(getLabeledCheckbox(questionIndex, examAnswer, visibleResult, enabled, i.isOdd));
      }
    }

    return [
      questionIndex > 0 ? const Divider(color: Colors.grey) : const SizedBox(height: 10),
      SizedBox(
          width: double.infinity,
          child: Text('${questionIndex+1}. ${examQuestion.text}', style: const TextStyle(fontWeight: FontWeight.bold))
      ),
      ...labeledAnswers
    ];
  }

  void _confirmAndProceed() {

    // save answer in preferences
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        if (_currentQuestionIndex < numOfExamQuestions) {
          prefs.setStringList(
              _getKeyCurrentQuestionAnswerIndex(_currentQuestionIndex),
              selectedAnswers[_currentQuestionIndex]!);
        }
      });
    });

    // restore current index
    if(_currentQuestionIndex < numOfExamQuestions) {
      _currentQuestionIndex++;
    }

    _checkIfPassed();

    _scrollToEnd();
  }

  void _checkIfPassed() {
    double percentagePassed = 0.0;
    for(int i = 0; i < _currentQuestionIndex; i++) {
      int numOfAnswers = examQuestions[i].examAnswers.length;
      int numOfCorrectAnswers = 0;
      int numOfCorrectlySelectedAnswers = 0;
      for(int j = 0; j < numOfAnswers; j++) {
        ExamAnswer examAnswer = examQuestions[i].examAnswers[j];
        bool selectedAnswer = selectedAnswers[i]!.contains(examAnswer.text); // selected by the user
        // count correct answers to determine if radio buttons, or checkboxes
        if(examAnswer.correct) {
          numOfCorrectAnswers++;
        }
        // increase counter for correctly selected answers only
        if((selectedAnswer && examAnswer.correct) || (!selectedAnswer && !examAnswer.correct)) {
          numOfCorrectlySelectedAnswers++;
        }
      }
      double percentageCorrectAnswers = numOfCorrectAnswers == 1 ? // should be 0/1 for radio buttons
        (numOfCorrectlySelectedAnswers == numOfAnswers ? 100 : 0) :
        (100 * numOfCorrectlySelectedAnswers / numOfAnswers); // should be [0,1] for checkboxes
      percentagePassed += percentageCorrectAnswers;
      debugPrint('percentagePassed: $percentagePassed -- (percentageCorrectAnswers: $percentageCorrectAnswers, numOfCorrectlySelectedAnswers: $numOfCorrectlySelectedAnswers, numOfAnswers: $numOfAnswers, numOfCorrectAnswers: $numOfCorrectAnswers)'); // todo delete
    }
    percentagePassed /= numOfExamQuestions;
    final bool passed = percentagePassed >= minPercentageToPass;

    setState(() {
      _percentagePassed = percentagePassed;
      _alreadyPassed = passed;
    });

    Provider.of<StoryProgress>(context, listen: false).setCompleted(
        widget.storyId, widget.component.id, passed);
  }

  _scrollToEnd() async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeIn);
    });
  }
}