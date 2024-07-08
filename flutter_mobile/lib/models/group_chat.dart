class GroupChatUser {
  final int id;
  final int groupChatId;
  final int userId;
  final String role;

  GroupChatUser({
    required this.id,
    required this.groupChatId,
    required this.userId,
    required this.role,
  });

  factory GroupChatUser.fromJson(Map<String, dynamic> json) {
    return GroupChatUser(
      id: json['ID'],
      groupChatId: json['GroupChatID'],
      userId: json['UserID'],
      role: json['Role'],
    );
  }
}

class GroupChat {
  final int id;
  final String name;
  final String activity;
  final String imageUrl;
  final String catchPhrase;
  final String lastMessage;
  final int unreadCount;
  final List<GroupChatUser> users;

  GroupChat({
    required this.id,
    required this.name,
    required this.activity,
    required this.catchPhrase,
    required this.imageUrl,
    this.lastMessage = "Dernier message ici", // Valeur en dur pour le moment
    this.unreadCount = 4, // Valeur en dur pour le moment
    required this.users,
  });

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      id: json['ID'],
      name: json['Name'],
      activity: json['Activity'],
      catchPhrase: json['CatchPhrase'],
      imageUrl: json['ImageUrl'] ?? '',
      users: (json['Users'] as List)
          .map((user) => GroupChatUser.fromJson(user))
          .toList(),
    );
  }

  bool isUserOwner(String userId) {
    return users.any(
        (user) => user.userId.toString() == userId && user.role == 'owner');
  }
}
