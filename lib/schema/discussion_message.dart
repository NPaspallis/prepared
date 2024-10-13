class DiscussionMessage {

  int senderIndex;
  String text;

  DiscussionMessage(this.senderIndex, this.text);

  @override
  String toString() {
    return 'DiscussionMessage{senderIndex: $senderIndex, text: $text}';
  }

}