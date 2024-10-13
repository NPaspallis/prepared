class MultipollEntry {

  final String _storyID;
  final String _deviceID;
  final List<int> _selectedOptionIndices;
  final String _pollID;

  MultipollEntry(this._storyID, this._deviceID, this._selectedOptionIndices, this._pollID);

  List<int> get selectedOptionIndices => _selectedOptionIndices;

  String get deviceID => _deviceID;

  String get storyID => _storyID;

  String get pollID => _pollID;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultipollEntry &&
          runtimeType == other.runtimeType &&
          _storyID == other._storyID &&
          _deviceID == other._deviceID;

  @override
  int get hashCode => _storyID.hashCode ^ _deviceID.hashCode;

  ///Converts a PollEntry object into a JSON-formatted map.
  Map<String, dynamic> toJson() => {
    "storyID": storyID,
    "deviceID": deviceID,
    "pollID": pollID,
    "selectedOptionIndices": selectedOptionIndices
  };

}