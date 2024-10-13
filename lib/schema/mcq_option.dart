class MCQOption {

  int id;
  String title;
  String description;
  String feedback;
  bool correct;


  MCQOption(
      this.id, this.title, this.description, this.feedback, this.correct);

  @override
  String toString() {
    return 'PollOption{id: $id, title: $title, description: $description, feedback: $feedback, correct: $correct}';
  }

}