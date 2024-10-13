import 'package:app/schema/component/component.dart';
import 'package:app/schema/component/component_type.dart';

class AudioComponent implements StoryComponent {

  String id;
  String audioURL;
  final ComponentType type = ComponentType.audio;
  String content;

  AudioComponent(this.id, this.audioURL, this.content);

  static AudioComponent fromJson(dynamic jsonObject) {
    return AudioComponent(
        jsonObject["id"],
        jsonObject["audioURL"],
        jsonObject["content"]
    );
  }

  @override
  String toString() {
    return 'AudioComponent{id: $id, audioURL: $audioURL, type: $type, content: $content}';
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