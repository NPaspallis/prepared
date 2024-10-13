class BadgeEntry {

  final String _badgeId;
  final String _name;
  final String _email;
  final String _date; // yyyy-MM-dd

  BadgeEntry(this._badgeId, this._name, this._email, this._date);

  String get badgeId => _badgeId;
  String get name => _name;
  String get email => _email;
  String get date => _date;


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeEntry &&
          runtimeType == other.runtimeType &&
          _badgeId == other._badgeId &&
          _name == other._name &&
          _email == other._email &&
          _date == other._date;

  @override
  int get hashCode =>
      _badgeId.hashCode ^ _name.hashCode ^ _email.hashCode ^ _date.hashCode;

  ///Converts a PollEntry object into a JSON-formatted map.
  Map<String, dynamic> toJson() => {
    "badgeId": badgeId,
    "name": name,
    "email": email,
    "date": date
  };

  @override
  String toString() {
    return 'BadgeEntry{_badgeId: $_badgeId, _name: $_name, _email: $_email, _date: $_date}';
  }
}