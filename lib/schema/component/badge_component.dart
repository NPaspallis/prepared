import 'package:app/schema/component/component.dart';
import 'package:app/schema/component/component_type.dart';

class BadgeComponent implements StoryComponent {

  final String id;
  final ComponentType type = ComponentType.badge;
  final String content;
  final String badgeName;
  final String badgeImageUrl;
  final String badgeClassId;
  final String issuerId;

  BadgeComponent(this.id, this.content, this.badgeName, this.badgeImageUrl, this.badgeClassId, this.issuerId);

  static BadgeComponent fromJson(dynamic jsonObject) {
    return BadgeComponent(
        jsonObject["id"],
        jsonObject["content"],
        jsonObject["badgeName"],
        jsonObject["badgeImageUrl"],
        jsonObject["badgeClassId"],
        jsonObject["issuerId"]
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

  @override
  String toString() {
    return 'BadgeComponent{id: $id, type: $type, content: $content, badgeName: $badgeName, badgeImageUrl: $badgeImageUrl, badgeClassId: $badgeClassId, issuerId: $issuerId}';
  }
}