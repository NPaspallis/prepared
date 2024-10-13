enum StoryCheckStatus {

  ok("Story check OK"),
  invalidStartingComponentID("Invalid starting component ID."),
  referenceDoesNotExist("A reference was created to a component that does not exist."),
  selfReference("Self-references are not possible in components."),
  invalidDiscussionParticipantID("Invalid discussion participant ID."),
  duplicateComponentID("Duplicate component ID found."),
  noBranchComponentOptions("Branch component has no options."),
  noSuchBucket("Referenced bucket (correctBucketID) does not exist."),

  ;

  final String errorMessage;

  const StoryCheckStatus(this.errorMessage);

}