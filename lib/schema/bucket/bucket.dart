class Bucket {

  final int id;
  final String label;

  Bucket(this.id, this.label);

  @override
  String toString() {
    return 'Bucket{id: $id, label: $label}';
  }

}