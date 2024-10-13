import 'package:app/schema/component/component.dart';
import 'package:app/schema/component/component_type.dart';

import '../poll_option.dart';

class PollComponent implements StoryComponent {

  String id;
  final ComponentType type = ComponentType.poll;
  List<PollOption> options;
  String prompt;
  String content;
  String feedback;

  PollComponent(
      this.id, this.options, this.prompt, this.content, this.feedback);
  
  static PollComponent fromJson(dynamic jsonObject) {
    
    List<PollOption> options = [];
    
    for (int i = 0; i < jsonObject["options"].length; i++) {
      PollOption option = PollOption(
          jsonObject["options"][i]["id"] as int,
          jsonObject["options"][i]["title"],
          jsonObject["options"][i]["description"],
          jsonObject["options"][i]["feedback"]
      );
      options.add(option);
    }
    
    return PollComponent(
      jsonObject["id"],
      options,
      jsonObject["prompt"],
      jsonObject["content"],
      jsonObject["feedback"]
    );
  }


  @override
  String toString() {
    return 'PollComponent{id: $id, type: $type, options: $options, prompt: $prompt, content: $content, feedback: $feedback}';
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