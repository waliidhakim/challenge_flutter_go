class GroupChat {
  final int id;
  final String name, activity, catchPhrase, imageUrl;

  GroupChat({
    required this.id,
    required this.name,
    required this.activity,
    required this.catchPhrase,
    required this.imageUrl,
  });

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      id: json['ID'],
      name: json['Name'],
      activity: json['Activity'],
      catchPhrase: json['CatchPhrase'],
      imageUrl: json['ImageUrl'],
    );
  }
}
