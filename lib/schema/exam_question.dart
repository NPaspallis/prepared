class ExamQuestion {

  String question;
  bool shuffledAnswers;
  List<ExamQuestionAnswer> examQuestionAnswers;

  ExamQuestion(this.question, this.shuffledAnswers, this.examQuestionAnswers);

  factory ExamQuestion.from({required String question, bool shuffledAnswers = false, required List<String> answers, required int correctIndex}) {
    List<ExamQuestionAnswer> examQuestionAnswers = [];
    for(int i = 0; i < answers.length; i++) {
      examQuestionAnswers.add(ExamQuestionAnswer(answers[i], i==correctIndex));
    }
    return ExamQuestion(question, shuffledAnswers, examQuestionAnswers);
  }

  @override
  String toString() {
    return 'ExamQuestion{question: $question, shuffledAnswers: $shuffledAnswers, examQuestionAnswers: $examQuestionAnswers}';
  }
}

class ExamQuestionAnswer {
  String answer;
  bool correct;

  ExamQuestionAnswer(this.answer, this.correct);

  @override
  String toString() {
    return 'ExamQuestionAnswer{answer: $answer, correct: $correct}';
  }
}