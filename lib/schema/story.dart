import 'package:app/schema/component/multipoll_component.dart';
import 'package:app/schema/component/video_component.dart';
import 'package:app/schema/story_metadata.dart';

import 'component/audio_component.dart';
import 'component/branch_component.dart';
import 'component/bucket_component.dart';
import 'component/chat_component.dart';
import 'component/component.dart';
import 'component/component_type.dart';
import 'component/discussion_component.dart';
import 'component/html_component.dart';
import 'component/mcq_component.dart';
import 'component/multimcq_component.dart';
import 'component/poll_component.dart';
import 'package:app/schema/component/badge_component.dart';
import 'component/exam_component.dart';

class Story {

  String id;
  String title;
  String shortTitle;
  String bannerImageURL;
  StoryMetadata metadata;
  String? password;
  String startingComponentID;
  List<StoryComponent> components;

  Story(this.id, this.title, this.shortTitle, this.bannerImageURL, this.metadata,
      this.password, this.startingComponentID, this.components);

  ///Decodes a Story and all its components from a JSON object.
  static Story fromJson(jsonObject) {

    StoryMetadata storyMetadata = StoryMetadata.fromJson(jsonObject["metadata"]);
    List<StoryComponent> components = [];

    for (int i = 0; i < jsonObject["components"].length; i++) {
      ComponentType type = ComponentType.fromText(jsonObject["components"][i]["type"]);
      StoryComponent component;
      switch (type) {
        case ComponentType.html:
          component = HtmlComponent.fromJson(jsonObject["components"][i]);
          break;
        case ComponentType.chat:
          component = ChatComponent.fromJson(jsonObject["components"][i]);
          break;
        case ComponentType.poll:
          component = PollComponent.fromJson(jsonObject["components"][i]);
          break;
        case ComponentType.multipoll:
          component = MultipollComponent.fromJson(jsonObject["components"][i]);
          break;
        case ComponentType.mcq:
          component = MCQComponent.fromJson(jsonObject["components"][i]);
          break;
        case ComponentType.multimcq:
          component = MultiMCQComponent.fromJson(jsonObject["components"][i]);
          break;
        case ComponentType.discussion:
          component = DiscussionComponent.fromJson(jsonObject["components"][i]);
          break;
        case ComponentType.video:
          component = VideoComponent.fromJson(jsonObject["components"][i]);
          break;
        case ComponentType.branch:
          component = BranchComponent.fromJson(jsonObject["components"][i]);
          break;
        case ComponentType.bucket:
          component = BucketComponent.fromJson(jsonObject["components"][i]);
          break;
        case ComponentType.audio:
          component = AudioComponent.fromJson(jsonObject["components"][i]);
          break;
        case ComponentType.badge:
          component = BadgeComponent.fromJson(jsonObject["components"][i]);
          break;
        case ComponentType.exam:
          component = ExamComponent.fromJson(jsonObject["components"][i]);
          break;
        default:
          throw FormatException("Invalid ComponentType '${type.name}'.");
      }
      components.add(component);

    }

    return Story(
      jsonObject["id"],
      jsonObject["title"],
      jsonObject["shortTitle"],
      jsonObject["bannerImageURL"],
      storyMetadata,
      jsonObject["password"],
      jsonObject["startingComponentID"],
      components
    );
  }

  String getAuthors() {
    String authors = "";
    for (String author in metadata.authors) {
      authors += "$author, ";
    }
    return authors.substring(0, authors.length - 2);
  }

  bool hasPassword() {
    return password != null && password.toString().isNotEmpty;
  }

  bool checkPassword(String? password) {
    return this.password != null && password != null && this.password.toString().trim() == password.trim();
  }

  ///Retrieves all components of a specific type.
  List<StoryComponent> getComponentsOfType(ComponentType type) {
    List<StoryComponent> components = [];
    for (StoryComponent component in this.components) {
      if (component.getType() == type) {
        components.add(component);
      }
    }
    return components;
  }

  ///Retrieves a component given its ID.
  StoryComponent? getComponentWithID(String id) {
    for (StoryComponent component in components) {
      if (component.getID() == id) {
        return component;
      }
    }
    return null;
  }

  ///Retrieves the starting component.
  StoryComponent? getStartingComponent() {
    return getComponentWithID(startingComponentID);
  }

  ///Retrieves the starting component's index.
  int? getIndexOfStartingComponent() {
    return getComponentIndex(startingComponentID);
  }

  ///Retrieves a component's index given its ID
  int? getComponentIndex(String id) {
    for (int i = 0; i < components.length; i++) {
      if (components[i].getID() == id) {
        return i;
      }
    }
    return null;
  }

  @override
  String toString() {
    return 'Story{id: $id}';
  }

  String toFullString() {
    return 'Story{id: $id, title: $title, bannerImageURL: $bannerImageURL, metadata: $metadata, password: $password, startingComponentID: $startingComponentID, components: $components}';
  }

}