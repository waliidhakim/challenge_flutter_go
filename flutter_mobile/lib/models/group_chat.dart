import 'package:flutter_mobile/models/user_model.dart';

class GroupChat {
  final int id;
  final String name;
  final String activity;
  final String imageUrl;
  final String catchPhrase;
  final String lastMessage;
  final int unreadCount;
  final User? owner; // Le propriétaire peut être null

  GroupChat({
    required this.id,
    required this.name,
    required this.activity,
    required this.catchPhrase,
    required this.imageUrl,
    this.lastMessage = "Dernier message ici", // Valeur en dur pour le moment
    this.unreadCount = 4, // Valeur en dur pour le moment
    this.owner, // Le propriétaire peut être null
  });

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      id: json['ID'],
      name: json['Name'],
      activity: json['Activity'],
      catchPhrase: json['CatchPhrase'],
      imageUrl: json['ImageUrl'] ?? '', // Gérer les valeurs null
      owner: json['Owner'] != null ? User.fromJson(json['Owner']) : null,
    );
  }
}
