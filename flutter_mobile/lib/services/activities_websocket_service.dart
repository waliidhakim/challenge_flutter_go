import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class ActivitiesWebSocketService {
  final String groupId;
  final Function(Map<String, dynamic>) onMessageReceived;
  late WebSocketChannel _channel;

  ActivitiesWebSocketService({
    required this.onMessageReceived,
    required this.groupId,
  });

  void connect() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://10.0.2.2:4000/ws'),
    );

    _channel.stream.listen((message) {
      final decodedMessage = jsonDecode(message);
      print("decodedMessage: $decodedMessage");
      onMessageReceived(decodedMessage);
    });
  }

  void groupParticipants(int nbParticipants) {
    print('groupParticipants called');
    print(nbParticipants);
    final groupParticipants = {
      'type': 'group_participants',
      'group_chat_id': int.parse(groupId),
      'nb_participants': nbParticipants,
    };
    _channel.sink.add(jsonEncode(groupParticipants));
  }

  void disconnect() {
    _channel.sink.close();
  }
}
