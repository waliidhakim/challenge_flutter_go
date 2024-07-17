import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final String userId;
  final String groupId;
  final String username;
  final Function(Map<String, dynamic>) onMessageReceived;
  final Function(bool) onTypingStatusChanged;
  late WebSocketChannel _channel;

  WebSocketService({
    required this.userId,
    required this.groupId,
    required this.username,
    required this.onMessageReceived,
    required this.onTypingStatusChanged,
  });

  void connect() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://10.0.2.2:4000/ws'),
    );

    _channel.stream.listen((message) {
      print("message from 1: $message");
      final decodedMessage = jsonDecode(message);
      if (decodedMessage['type'] == 'typing' ||
          decodedMessage['type'] == 'stop_typing') {
        if (decodedMessage['sender_id'] != userId) {
          onTypingStatusChanged(decodedMessage['type'] == 'typing');
        }
      } else {
        onMessageReceived(decodedMessage);
      }
    });
  }

  void startTyping() {
    final typingMessage = {
      'type': 'typing',
      'sender_id': userId,
      'group_chat_id': int.parse(groupId),
      'username': username,
    };
    _channel.sink.add(jsonEncode(typingMessage));
  }

  void stopTyping() {
    final stopTypingMessage = {
      'type': 'stop_typing',
      'sender_id': userId,
      'group_chat_id': int.parse(groupId),
      'username': username,
    };
    _channel.sink.add(jsonEncode(stopTypingMessage));
  }

  void sendMessage(String message) {
    final chatMessage = {
      'type': 'message',
      'sender_id': userId,
      'group_chat_id': int.parse(groupId),
      'username': username,
      'message': message,
      'created_at': DateTime.now()
          .toUtc()
          .toIso8601String(), // Ajouter l'heure de création au format UTC
    };
    _channel.sink.add(jsonEncode(chatMessage));
  }

  void groupParticipants(int nbParticipants) {
    final groupParticipants = {
      'type': 'group_participants',
      'group_chat_id': int.parse(groupId),
      'nb_participants': nbParticipants,
    };
    _channel.sink.add(jsonEncode(groupParticipants));
  }

  void groupVotes() {
    final groupVotes = {
      'type': 'group_votes',
      'group_chat_id': int.parse(groupId),
    };
    _channel.sink.add(jsonEncode(groupVotes));
  }

  void disconnect() {
    _channel.sink.close();
  }
}
