import 'package:app/schema/component/component.dart';
import 'package:app/schema/component/component_type.dart';

import 'component_choice.dart';

class BranchComponent implements StoryComponent {

  String id;
  final ComponentType type = ComponentType.branch;
  String? content;
  List<ComponentChoice> choices;

  BranchComponent(this.id, this.choices, [this.content]);

  static BranchComponent fromJson(dynamic jsonObject) {
    return BranchComponent(
        jsonObject["id"],
        decodeComponentChoices(jsonObject["choices"]),
        jsonObject["content"]
    );
  }

  @override
  String toString() {
    return 'BranchComponent{id: $id, type: $type, choices: $choices}';
  }

  @override
  String getID() {
    return id;
  }

  @override
  ComponentType getType() {
    return type;
  }

  List<ComponentChoice> getChoices() {
    return choices;
  }

  ///Decodes the components of a story.
  static List<ComponentChoice> decodeComponentChoices(dynamic jsonObject) {
    List<ComponentChoice> choices = [];
    for (int i = 0; i < jsonObject.length; i++) {
      ComponentChoice choice = ComponentChoice(
          jsonObject[i]["linkedComponentID"],
          jsonObject[i]["label"]
      );
      choices.add(choice);
    }
    return choices;
  }

}