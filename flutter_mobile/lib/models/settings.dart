enum NotificationLevel { all, partial, none }

class Setting {
  final int ?id;
  final NotificationLevel notifyLevel;
  final int notifyThreshold;
  final int ?userID;

  Setting({
    this.id,
    required this.notifyLevel,
    required this.notifyThreshold,
    this.userID,
  });

  factory Setting.fromJson(Map<String, dynamic> json) {
    return Setting(
      id: json['ID'],
      notifyLevel: NotificationLevel.values.byName(json['NotifyLevel']),
      notifyThreshold: json['NotifyThreshold'],
      userID: json['UserID'],
    );
  }
}
