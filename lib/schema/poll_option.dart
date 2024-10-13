class PollOption {

  int id;
  String title;
  String description;
  String? feedback;

  PollOption(this.id, this.title, this.description, [this.feedback]);

  @override
  String toString() {
    return 'PollOption{id: $id, title: $title, description: $description}';
  }

}