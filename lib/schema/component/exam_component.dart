import 'package:app/schema/component/component.dart';
import 'package:app/schema/component/component_type.dart';
import 'package:app/schema/exam/exam_question.dart';
import 'package:app/schema/exam/exam_answer.dart';

class ExamComponent implements StoryComponent {

  final String id;
  final ComponentType type = ComponentType.exam;
  final String content;
  List<ExamQuestion> questions;
  final double minPercentageToPass;

  ExamComponent(this.id, this.content, this.questions, this.minPercentageToPass);

  static ExamComponent fromJson(dynamic jsonObject) {
    List<ExamQuestion> questions = [];
    for (int i = 0; i < jsonObject["questions"].length; i++) {
      List<ExamAnswer> examAnswers = [];
      for(int j = 0; j < jsonObject["questions"][i]["answers"].length; j++) {
        examAnswers.add(ExamAnswer(
            jsonObject["questions"][i]["answers"][j]["text"] as String,
            (jsonObject["questions"][i]["answers"][j]["correct"] ?? false) as bool // by default false
        ));
      }
      ExamQuestion examQuestion = ExamQuestion(
          jsonObject["questions"][i]["text"],
          (jsonObject["questions"][i]["shuffledAnswers"] ?? false) as bool, // if not defined, then false
          examAnswers
      );
      questions.add(examQuestion);
    }

    return ExamComponent(
        jsonObject["id"],
        jsonObject["content"],
        questions,
        jsonObject["minPercentageToPass"]
    );
  }

  @override
  String getID() => id;

  @override
  ComponentType getType()=> type;
}