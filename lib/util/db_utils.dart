import 'package:app/schema/component/component.dart';
import 'package:app/schema/component/multipoll_component.dart';
import 'package:app/schema/component/poll_component.dart';
import 'package:app/util/pref_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../schema/story.dart';

class DBUtils {

  ///Deletes all poll votes for a story.
  static Future<void> deleteAllPollVotes(String deviceID, Story story) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var batch = firestore.batch();
    for (StoryComponent component in story.components) {
      if (component is PollComponent || component is MultipollComponent) {
        String pollEntryID = PreferenceUtils.constructPollEntryID(deviceID, story.id, component.getID());
        var documentReference = firestore.collection("PollEntry").doc(pollEntryID);
        batch.delete(documentReference);
      }
    }
    await batch.commit();
  }

}