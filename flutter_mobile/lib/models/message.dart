class Message {
  String type;
  String message;
  String senderId;
  String username;

  Message({
    required this.type,
    required this.message,
    required this.senderId,
    required this.username,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      type: json['type'],
      message: json['message'] ?? '',
      senderId: json['sender_id'].toString(),
      username: json['username'] ?? '',
    );
  }
}
