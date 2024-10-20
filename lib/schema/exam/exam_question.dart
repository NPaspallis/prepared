import 'exam_answer.dart';

class ExamQuestion {

  String text;
  bool shuffledAnswers;
  List<ExamAnswer> examAnswers;

  ExamQuestion(this.text, this.shuffledAnswers, this.examAnswers);

  @override
  String toString() {
    return 'ExamQuestion{text: $text, shuffledAnswers: $shuffledAnswers, examAnswers: $examAnswers}';
  }
}