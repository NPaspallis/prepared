import 'package:app/schema/component/component.dart';
import 'package:app/schema/component/component_type.dart';
import 'package:app/schema/mcq_option.dart';

import '../poll_option.dart';

class MultiMCQComponent implements StoryComponent {

  String id;
  final ComponentType type = ComponentType.multimcq;
  List<MCQOption> options;
  String prompt;
  String content;
  String feedback;
  int? maxSelections;

  MultiMCQComponent(
      this.id, this.options, this.prompt,
      this.content, this.feedback, this.maxSelections
  );
  
  static MultiMCQComponent fromJson(dynamic jsonObject) {
    
    List<MCQOption> options = [];

    for (int i = 0; i < jsonObject["options"].length; i++) {
      MCQOption option = MCQOption(
          jsonObject["options"][i]["id"] as int,
          jsonObject["options"][i]["title"],
          jsonObject["options"][i]["description"],
          jsonObject["options"][i]["feedback"],
          jsonObject["options"][i]["correct"] as bool
      );
      options.add(option);
    }
    
    return MultiMCQComponent(
      jsonObject["id"],
      options,
      jsonObject["prompt"],
      jsonObject["content"],
      jsonObject["feedback"],
      jsonObject["maxSelections"] != null ? jsonObject["maxSelections"] as int : null
    );
  }


  @override
  String toString() {
    return 'MultipollComponent{id: $id, type: $type, options: $options, prompt: '
        '$prompt, content: $content, feedback: $feedback, maxSelections: '
        '$maxSelections}';
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