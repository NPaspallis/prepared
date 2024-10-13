class StoryMetadata {

  List<String> authors;
  int createdOn;
  int lastEdited;

  StoryMetadata(this.authors, this.createdOn, this.lastEdited);

  //Decodes a StoryMetadata object form a JSON obejct.
  static StoryMetadata fromJson(jsonObject) {
    List<String> authors = [];

    for (int i = 0; i < jsonObject["authors"].length; i++) {
      authors.add(jsonObject["authors"][i].toString());
    }

    int createdOn = jsonObject["createdOn"];
    int lastEdited = jsonObject["lastEdited"];
    return StoryMetadata(authors, createdOn, lastEdited);
  }

  @override
  String toString() {
    return 'StoryMetadata{authors: $authors, createdOn: $createdOn, lastEdited: $lastEdited}';
  }

}