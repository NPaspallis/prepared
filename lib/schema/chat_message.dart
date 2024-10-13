class ChatMessage {

  String senderName;
  String text;
  int timestamp;
  int upvotes;
  int downvotes;

  ChatMessage(
      this.senderName, this.text, this.timestamp, this.upvotes, this.downvotes);

  @override
  String toString() {
    return 'ChatMessage{senderName: $senderName, text: $text, timestamp: $timestamp, upvotes: $upvotes, downvotes: $downvotes}';
  }

}