import 'package:app/schema/component/component.dart';
import 'package:app/schema/component/component_type.dart';

class VideoComponent implements StoryComponent {

  String id;
  String videoURL;
  final ComponentType type = ComponentType.video;
  String content;
  String? subtitlesURL;
  int? startTime;
  int? endTime;

  VideoComponent(this.id, this.videoURL, this.content, [this.subtitlesURL, this.startTime, this.endTime]);

  static VideoComponent fromJson(dynamic jsonObject) {
    return VideoComponent(
        jsonObject["id"],
        jsonObject["videoURL"],
        jsonObject["content"],
        jsonObject["subtitlesURL"],
        jsonObject["startTime"],
        jsonObject["endTime"]
    );
  }

  @override
  String toString() {
    return 'VideoComponent{id: $id, videoURL: $videoURL, type: $type, content: $content}';
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