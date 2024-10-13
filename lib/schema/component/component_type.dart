enum ComponentType {

  html("html"),
  chat("chat"),
  poll("poll"),
  multipoll("multipoll"),
  discussion("discussion"),
  video("video"),
  branch("branch"),
  bucket("bucket"),
  mcq("mcq"),
  multimcq("multimcq"),
  audio("audio"),
  badge("badge"),
  exam("exam"),
  ;

  final String text;
  const ComponentType(this.text);

  static ComponentType fromText(String text) {
    switch (text) {
      case "html": return ComponentType.html;
      case "chat": return ComponentType.chat;
      case "poll": return ComponentType.poll;
      case "multipoll": return ComponentType.multipoll;
      case "discussion": return ComponentType.discussion;
      case "video": return ComponentType.video;
      case "branch": return ComponentType.branch;
      case "bucket": return ComponentType.bucket;
      case "mcq": return ComponentType.mcq;
      case "multimcq": return ComponentType.multimcq;
      case "audio": return ComponentType.audio;
      case "badge": return ComponentType.badge;
      case "exam": return ComponentType.exam;
      default: throw FormatException("Invalid ComponentType '$text'.");
    }
  }

}