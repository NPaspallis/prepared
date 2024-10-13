import 'package:app/schema/component/component.dart';

import '../chat_message.dart';
import 'component_type.dart';

class ChatComponent implements StoryComponent {

  String id;
  final ComponentType type = ComponentType.chat;
  String content;
  List<ChatMessage> messages;

  ChatComponent(
      this.id, this.content, this.messages);

  static ChatComponent fromJson(dynamic jsonObject) {

    return ChatComponent(
        jsonObject["id"],
        jsonObject["content"],
        []
    );
  }

  @override
  String toString() {
    return 'ChatComponent{id: $id, componentType: $type, content: $content, messages: $messages}';
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