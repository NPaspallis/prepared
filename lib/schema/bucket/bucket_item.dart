import 'bucket.dart';

class BucketItem {

  final int id;
  final int correctBucketID;
  final String label;
  Bucket? _currentBucket;

  BucketItem(this.id, this.correctBucketID, this.label);

  ///Puts a bucket item into the specified bucket.
  putInBucket(Bucket bucket) {
    _currentBucket = bucket;
  }

  //Checks if the bucket item is in the specified bucket.
  bool isInBucket(Bucket bucket) {
    if (_currentBucket == null) return false;
    return _currentBucket?.id == bucket.id;
  }

  bool isInCorrectBucket() {
    if (_currentBucket == null) return false;
    return _currentBucket?.id == correctBucketID;
  }

  ///Removes an item from a bucket.
  removeFromBucket() {
    _currentBucket = null;
  }

  ///Checks if the item is not in a bucket.
  bool isNotInABucket() {
    return (_currentBucket == null);
  }

  @override
  String toString() {
    return 'BucketItem{id: $id, label: $label}';
  }

}