class Activity {
  final int ?id;
  final int ?userID;
  final int ?groupID;
  final DateTime ?participationDate;

  Activity({
    this.id,
    this.userID,
    this.groupID,
    this.participationDate,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['ID'],
      userID: json['UserID'],
      groupID: json['GroupChatID'],
      participationDate: DateTime.parse(json['ParticipationDate']),
    );
  }
}
