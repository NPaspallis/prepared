import 'package:app/schema/component/branch_component.dart';
import 'package:app/schema/component/bucket_component.dart';
import 'package:app/schema/component/component_choice.dart';
import 'package:app/schema/component/component_type.dart';
import 'package:app/schema/component/discussion_component.dart';
import 'package:app/schema/discussion_message.dart';

import '../schema/bucket/bucket.dart';
import '../schema/bucket/bucket_item.dart';
import '../schema/component/component.dart';
import '../schema/story.dart';
import '../schema/story_check_status.dart';

///A utility class that enables text validation using regular expressions.
class ValidationUtils {

  ///Checks if a given name is valid (alphanumeric and dash only)
  static bool isValidName(String name) {
    final regExp = RegExp(r"^[a-zA-Z0-9-']+$");
    return regExp.hasMatch(name);
  }

  ///Checks the story references to make sure each reference exists in the data.
  static StoryCheckStatus checkStoryReferences(Story story) {
    bool validStartingComponentID = false;

    for (int i = 0; i < story.components.length; i++) {
      //startingComponentID:
      if (story.components[i].getID() == story.startingComponentID) {
        validStartingComponentID = true;
      }
    }

    //Check if there are any duplicate IDs:
    for (int i = 0; i < story.components.length; i++) {
      for (int j = 1; j < story.components.length; j++) {
        if (i != j) {
          if (story.components[i].getID() == story.components[j].getID()) {
            return StoryCheckStatus.duplicateComponentID;
          }
        }
      }
    }

    //Find all branch components for checking
    List<BranchComponent> branchedComponents = [];
    List<ComponentChoice> allChoices = [];
    for (StoryComponent component in story.components) {
      if (component.getType() == ComponentType.branch) {
        BranchComponent branchComponent = component as BranchComponent;
        branchedComponents.add(branchComponent);
        allChoices.addAll(branchComponent.choices);
      }
    }

    //Find all component IDs for checking
    List<String> storyComponentIDs = [];
    for (StoryComponent c in story.components) {
      storyComponentIDs.add(c.getID());
    }

    //Check bucket component bucket items for existing correct bucket refs:
    for (StoryComponent c in story.components) {
      if (c.getType() == ComponentType.bucket) {
        BucketComponent bucketComponent = c as BucketComponent;
        List<int> bucketIDs = [];
        for (Bucket bucket in bucketComponent.buckets) {
          bucketIDs.add(bucket.id);
        }
        for (BucketItem item in bucketComponent.items) {
          if (!bucketIDs.contains(item.correctBucketID)) {
            return StoryCheckStatus.noSuchBucket;
          }
        }
      }
    }

    //Ensure the references exist:
    for (ComponentChoice choice in allChoices) {
      if (!storyComponentIDs.contains(choice.linkedComponentID)) {
        return StoryCheckStatus.referenceDoesNotExist;
      }
    }

    //Make sure there are no self-references in branch components
    //Make sure that all branch components have at least 1 branch path
    for (BranchComponent component in branchedComponents) {
      for (ComponentChoice choice in component.getChoices()) {
        if (choice.linkedComponentID == component.getID()) {
          return StoryCheckStatus.selfReference;
        }
      }

      if (component.choices.isEmpty) {
        return StoryCheckStatus.noBranchComponentOptions;
      }
    }

    //DiscussionMessage - senderIndex
    List<StoryComponent> discussionComponents =
        story.getComponentsOfType(ComponentType.discussion);
    for (StoryComponent component in discussionComponents) {
      DiscussionComponent discussionComponent =
          component as DiscussionComponent;
      for (DiscussionMessage message in discussionComponent.messages) {
        if (message.senderIndex >= component.participants.length ||
            message.senderIndex < 0) {
          print("Invalid participant ID: ${message.senderIndex}.");
          return StoryCheckStatus.invalidDiscussionParticipantID; //Invalid Participant ID.
        }
      }
    }

    if (!validStartingComponentID) {
      // print("Invalid startingComponentID in story ${story.id}");
      return StoryCheckStatus.invalidStartingComponentID;
    }

    return StoryCheckStatus.ok;
  }
}
