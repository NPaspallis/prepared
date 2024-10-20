class ExamAnswer {
  String text;
  bool correct;

  ExamAnswer(this.text, this.correct);

  factory ExamAnswer.from({required String text, bool correct = false}) {
    return ExamAnswer(text, correct);
  }

  @override
  String toString() {
    return 'ExamAnswer{answer: $text, correct: $correct}';
  }
}