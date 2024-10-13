import 'dart:math';

import 'package:app/model/story_progress.dart';
import 'package:app/schema/exam_question.dart';
import 'package:app/ui/component_views/labeled_radio.dart';
import 'package:app/ui/styles/style.dart';
import 'package:app/ui/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../schema/component/exam_component.dart';
import '../../util/pref_utils.dart';

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

  bool alreadyPassed = false;

  String _getKeyCurrentQuestionIndex() {
    return '${PreferenceUtils.keyCurrentQuestionIndex}-${widget.storyId}-${widget.component.id}';
  }

  String _getKeyCurrentQuestionAnswerIndex(int answerId) {
    return '${PreferenceUtils.keyCurrentQuestionAnswerIndex}-${widget.storyId}-${widget.component.id}-$answerId';
  }

  late String content;
  late List<ExamQuestion> examQuestions;
  late List<List<ExamQuestionAnswer>> examQuestionsAnswers;
  late int numOfExamQuestions;
  late int minNumOfCorrectToPass;
  late List<String> selectedAnswers;

  int _numPassed = 0;

  @override
  void initState() {
    super.initState();
    content = widget.component.content;
    examQuestions = widget.component.questions;
    numOfExamQuestions = examQuestions.length;
    examQuestionsAnswers = List.filled(numOfExamQuestions, []);
    for(int i = 0; i < numOfExamQuestions; i++) {
      examQuestionsAnswers[i] = examQuestions[i].examQuestionAnswers;
      if(examQuestions[i].shuffledAnswers) {
        examQuestions[i].examQuestionAnswers.shuffle();
      }
    }
    selectedAnswers = List<String>.filled(numOfExamQuestions, '');
    minNumOfCorrectToPass = widget.component.minNumOfCorrectToPass;

    alreadyPassed = Provider.of<StoryProgress>(context, listen: false).isCompleted(widget.storyId, widget.component.id);

    // restore current index
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _currentQuestionIndex = prefs.getInt(_getKeyCurrentQuestionIndex()) ?? 0;
        for(int i = 0; i < numOfExamQuestions; i++) {
          selectedAnswers[i] = prefs.getString(_getKeyCurrentQuestionAnswerIndex(i)) ?? '';
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
        prefs.setString(_getKeyCurrentQuestionAnswerIndex(i), selectedAnswers[i]);
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
                    Expanded(child: Text(
                        minNumOfCorrectToPass >= numOfExamQuestions ?
                            'Answer correctly all $numOfExamQuestions questions to pass.' :
                            'Answer correctly at least $minNumOfCorrectToPass of $numOfExamQuestions questions to pass.',
                        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)))
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
        _currentQuestionIndex < numOfExamQuestions && selectedAnswers[_currentQuestionIndex].isNotEmpty ? () => _confirmAndProceed() : null,
        key: const Key('button-confirm-and-proceed'),
      );
    }
    else {
      String passedQuestions = _numPassed == numOfExamQuestions ? 'all' : '$_numPassed of $numOfExamQuestions';
      if(alreadyPassed) {
        return RichText(
          text: TextSpan(
            text: '',
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              const TextSpan(text: 'Well done! ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: 'You answered $passedQuestions questions correctly. '),
              const TextSpan(text: 'You can proceed to the next page.')
            ],
          ),
        );
      } else {
        return Column(
          children: [
            Text('You answered $passedQuestions questions correctly, which is below the required threshold of $minNumOfCorrectToPass.', style: const TextStyle(color: Colors.red)),
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
        selectedAnswers[i] = '';
      }
    });
  }

  LabeledRadio getLabeledRadio(int questionIndex, ExamQuestionAnswer examQuestionAnswer, final bool visibleResult, final bool enabled) {

    return LabeledRadio(
      label: examQuestionAnswer.answer,
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      value: examQuestionAnswer.answer,
      groupValue: selectedAnswers[questionIndex],
      onChanged: (String newValue) {
        setState(() {
          selectedAnswers[questionIndex] = newValue;
        });
      },
      correct: examQuestionAnswer.correct,
      visibleResult: visibleResult,
      enabled: enabled,
    );
  }

  List<Widget> getQuestionWidget(final int questionIndex, final bool visibleResult, final bool enabled) {

    final ExamQuestion examQuestion = examQuestions[questionIndex];

    // produce a labeledRadio for each possible answer
    List<ExamQuestionAnswer> selectedExamQuestionAnswers = examQuestionsAnswers[questionIndex];
    List<LabeledRadio> labeledRadios = [];
    for(ExamQuestionAnswer examQuestionAnswer in selectedExamQuestionAnswers) {
      labeledRadios.add(getLabeledRadio(questionIndex, examQuestionAnswer, visibleResult, enabled));
    }

    return [
      questionIndex > 0 ? const Divider(color: Colors.grey) : const SizedBox(height: 10),
      SizedBox(
          width: double.infinity,
          child: Text('${questionIndex+1}. ${examQuestion.question}', style: const TextStyle(fontWeight: FontWeight.bold))
      ),
      ...labeledRadios
    ];
  }

  void _confirmAndProceed() {

    // save answer in preferences
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        if (_currentQuestionIndex < numOfExamQuestions) {
          prefs.setString(
              _getKeyCurrentQuestionAnswerIndex(_currentQuestionIndex),
              selectedAnswers[_currentQuestionIndex]);
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
    _numPassed = 0;
    for(int i = 0; i < _currentQuestionIndex; i++) {
      if(_checkIfCorrectAnswer(examQuestions[i], selectedAnswers[i])) {
        _numPassed++;
      }
    }
    final bool passed = _numPassed >= minNumOfCorrectToPass;

    setState(() => alreadyPassed = passed);

    Provider.of<StoryProgress>(context, listen: false).setCompleted(
        widget.storyId, widget.component.id, passed);
  }

  bool _checkIfCorrectAnswer(final ExamQuestion examQuestion, final String answer) {
    for(ExamQuestionAnswer examQuestionAnswer in examQuestion.examQuestionAnswers) {
      if(examQuestionAnswer.answer == answer) return examQuestionAnswer.correct;
    }
    return false;
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