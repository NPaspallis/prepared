class PollEntry {

  final String _storyID;
  final String _deviceID;
  final int _selectedOptionIndex;
  final String _pollID;

  PollEntry(this._storyID, this._deviceID, this._selectedOptionIndex, this._pollID);

  int get selectedOptionIndex => _selectedOptionIndex;

  String get deviceID => _deviceID;

  String get storyID => _storyID;

  String get pollID => _pollID;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PollEntry &&
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
    "selectedOptionIndex": selectedOptionIndex
  };

}