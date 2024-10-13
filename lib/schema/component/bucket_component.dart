import 'package:app/schema/component/component.dart';
import 'package:app/schema/component/component_type.dart';

import '../bucket/bucket.dart';
import '../bucket/bucket_item.dart';

class BucketComponent implements StoryComponent {

  final String id;
  final ComponentType type = ComponentType.bucket;
  final String _title;
  final String _description;
  final String _feedback;
  final List<Bucket> _buckets;
  final List<BucketItem> _items;

  BucketComponent(this.id, this._title, this._description, this._feedback, this._buckets, this._items);

  static BucketComponent fromJson(dynamic jsonObject) {
    return BucketComponent(
        jsonObject["id"],
        jsonObject["title"],
        jsonObject["description"],
        jsonObject["feedback"],
        decodeBuckets(jsonObject["buckets"]),
        decodeItems(jsonObject["bucket_items"]),
    );
  }

  @override
  String getID() {
    return id;
  }

  @override
  ComponentType getType() {
    return type;
  }

  String get title => _title;
  String get description => _description;
  String get feedback => _feedback;
  List<Bucket> get buckets => List<Bucket>.from(_buckets); // shallow copy
  List<BucketItem> get items => List<BucketItem>.from(_items); // shallow copy

  @override
  String toString() {
    return 'BucketComponent{id: $id, type: $type, title: $title, description: $description, feedback: $feedback, buckets: $buckets, items: $items}';
  }

  ///Decodes the buckets of the component:
  static List<Bucket> decodeBuckets(dynamic jsonObject) {
    final List<Bucket> buckets = [];
    for (int i = 0; i < jsonObject.length; i++) {
      Bucket bucket = Bucket(
        jsonObject[i]["id"] as int,
        jsonObject[i]["label"]
      );
      buckets.add(bucket);
    }
    return buckets;
  }

  ///Decodes the bucket items of the component:
  static List<BucketItem> decodeItems(dynamic jsonObject) {
    final List<BucketItem> items = [];
    for (int i = 0; i < jsonObject.length; i++) {
      BucketItem bucketItem = BucketItem(
          jsonObject[i]["id"] as int,
          jsonObject[i]["correctBucketID"] as int,
          jsonObject[i]["label"]
      );
      items.add(bucketItem);
    }
    return items;
  }
}