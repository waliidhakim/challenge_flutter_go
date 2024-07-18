class Notif {
  final int id;
  final String icon;
  final String title;
  final DateTime datetime;
  final String? content;
  final String groupName;
  final int groupID;
  final int userID;

  Notif({
    required this.icon,
    required this.title,
    required this.datetime,
    this.content,
    required this.groupName,
    required this.groupID,
    required this.userID,
    required this.id,
  });

  factory Notif.fromJson(Map<String, dynamic> json) {
    return Notif(
        id: json['ID'],
        title: json['Title'],
        icon: json['NotificationIcon'],
        content: json['Content'],
        datetime: DateTime.parse(json['DateTime']),
        groupName: json['GroupName'],
        groupID: json['GroupId'],
        userID: json['UserID']);
  }
}
