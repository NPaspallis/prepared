import 'package:app/schema/component/component.dart';
import 'package:app/schema/component/component_type.dart';
import 'package:app/schema/exam_question.dart';

class ExamComponent implements StoryComponent {

  final String id;
  final ComponentType type = ComponentType.exam;
  final String content;
  List<ExamQuestion> questions;
  final int minNumOfCorrectToPass;

  ExamComponent(this.id, this.content, this.questions,
      this.minNumOfCorrectToPass);

  static ExamComponent fromJson(dynamic jsonObject) {
    List<ExamQuestion> questions = [];
    for (int i = 0; i < jsonObject["questions"].length; i++) {
      List<String> answers = [];
      for(int j = 0; j < jsonObject["questions"][i]["answers"].length; j++) {
        answers.add(jsonObject["questions"][i]["answers"][j] as String);
      }
      ExamQuestion testQuestion = ExamQuestion.from(
          question: jsonObject["questions"][i]["question"],
          shuffledAnswers: (jsonObject["questions"][i]["shuffledAnswers"] ?? false) as bool, // if not defined, then false
          answers: answers,
          correctIndex: jsonObject["questions"][i]["correctIndex"] as int
      );
      questions.add(testQuestion);
    }

    return ExamComponent(
        jsonObject["id"],
        jsonObject["content"],
        questions,
        jsonObject["minNumOfCorrectToPass"]
    );
  }

  @override
  String getID() {
    return id;
  }

  @override
  ComponentType getType() {
    return type;
  }
}