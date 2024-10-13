import 'package:app/schema/component/component.dart';

import '../discussion_message.dart';
import '../participant.dart';
import 'component_type.dart';

class DiscussionComponent implements StoryComponent {

  String id;
  final ComponentType type = ComponentType.discussion;
  List<Participant> participants;
  List<DiscussionMessage> messages;

  DiscussionComponent(
      this.id, this.participants, this.messages);

  static DiscussionComponent fromJson(dynamic jsonObject) {

    List<Participant> participants = [];
    List<DiscussionMessage> messages = [];

    for (int i = 0; i < jsonObject["participants"].length; i++) {
      Participant participant = Participant(
          jsonObject["participants"][i]["name"],
          jsonObject["participants"][i]["image"],
      );
      participants.add(participant);
    }

    for (int i = 0; i < jsonObject["messages"].length; i++) {
      DiscussionMessage message = DiscussionMessage(
          jsonObject["messages"][i]["senderIndex"] as int,
          jsonObject["messages"][i]["text"]
      );
      messages.add(message);
    }

    return DiscussionComponent(
        jsonObject["id"],
        participants,
        messages
    );
  }

  @override
  String toString() {
    return 'DiscussionComponent{id: $id, type: $type, participants: $participants, messages: $messages}';
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