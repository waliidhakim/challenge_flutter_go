import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:go_router/go_router.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;

  const GroupChatScreen({super.key, required this.groupId});

  static String routeName = '/groupChat';

  static Future<void> navigateTo(BuildContext context, String groupId) {
    return context.push(routeName, extra: groupId);
  }

  @override
  GroupChatScreenState createState() => GroupChatScreenState();
}

class GroupChatScreenState extends State<GroupChatScreen> {
  final List<Map<String, String>> messages = [];
  late TextEditingController _controller;
  late WebSocketChannel channel;
  final String userId = sharedPrefs.userId; // Unique client ID
  final String username = sharedPrefs.username; // Unique client ID
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    print('Connecting to WebSocket...');
    try {
      channel = WebSocketChannel.connect(
        Uri.parse('ws://10.0.2.2:4000/ws'),
      );
      isConnected = true;
      channel.stream.listen(
        (message) {
          print('Received message: $message');
          final decodedMessage = jsonDecode(message);
          if (decodedMessage['sender_id'] != userId) {
            if (mounted) {
              setState(() {
                messages.add({
                  "sender_id": decodedMessage['sender_id'],
                  "username": decodedMessage['username'],
                  "message": decodedMessage['message'],
                });
              });
            }
          }
        },
        onDone: () {
          print('WebSocket connection closed');
          if (mounted) {
            setState(() {
              isConnected = false;
            });
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          if (mounted) {
            setState(() {
              isConnected = false;
            });
          }
        },
      );
    } catch (e) {
      print('Error connecting to WebSocket: $e');
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty && isConnected) {
      final message = jsonEncode({
        "message": _controller.text,
        "user_id": int.parse(userId), // Convertir en entier ici
        "username": username,
        "group_chat_id":
            int.parse(widget.groupId), // Utilisez le groupId du widget
        "sender_id": userId, // Utiliser l'ID utilisateur comme sender_id
      });
      print('Sending message: $message');
      try {
        channel.sink.add(message);
        if (mounted) {
          setState(() {
            messages.add({
              "sender_id": userId,
              "username": username,
              "message": _controller.text,
            });
            _controller.clear();
          });
        }
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  @override
  void dispose() {
    print('Disposing GroupChatScreen...');
    _controller.dispose();
    if (isConnected) {
      try {
        print('Closing WebSocket connection...');
        channel.sink.close(status.goingAway).then((_) {
          print('WebSocket closed');
        }).catchError((error) {
          print('Error closing WebSocket: $error');
        });
      } catch (e) {
        print('Error closing WebSocket: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Group")),
      body: FocusScope(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isMe = message["sender_id"] == userId;
                  return ListTile(
                    title: Text(isMe ? "Me" : message["username"]!),
                    subtitle: Text(message["message"]!),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type your message here...',
                      ),
                      onSubmitted: (_) {
                        // Fermer le clavier lorsqu'on appuie sur "Enter"
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
