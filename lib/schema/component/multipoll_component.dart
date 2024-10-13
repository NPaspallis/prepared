import 'package:app/schema/component/component.dart';
import 'package:app/schema/component/component_type.dart';

import '../poll_option.dart';

class MultipollComponent implements StoryComponent {

  String id;
  final ComponentType type = ComponentType.multipoll;
  List<PollOption> options;
  String prompt;
  String content;
  String feedback;
  int? maxSelections;

  MultipollComponent(
      this.id, this.options, this.prompt,
      this.content, this.feedback, this.maxSelections
  );
  
  static MultipollComponent fromJson(dynamic jsonObject) {
    
    List<PollOption> options = [];

    for (int i = 0; i < jsonObject["options"].length; i++) {
      PollOption option = PollOption(
          jsonObject["options"][i]["id"] as int,
          jsonObject["options"][i]["title"],
          jsonObject["options"][i]["description"],
          jsonObject["options"][i]["feedback"],
      );
      options.add(option);
    }
    
    return MultipollComponent(
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