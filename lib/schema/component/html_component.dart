import 'package:app/schema/component/component.dart';
import 'package:app/schema/component/component_type.dart';

class HtmlComponent implements StoryComponent {

  String id;
  final ComponentType type = ComponentType.html;
  String content;

  HtmlComponent(this.id, this.content);

  static HtmlComponent fromJson(dynamic jsonObject) {
    return HtmlComponent(
        jsonObject["id"],
        jsonObject["content"]
    );
  }

  @override
  String toString() {
    return 'HtmlComponent{id: $id, type: $type, content: $content}';
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