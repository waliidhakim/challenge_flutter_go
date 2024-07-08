import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';
import 'package:flutter_mobile/services/websocket_service.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen(
      {super.key, required this.groupId, required this.groupName});

  static String routeName = '/groupChat';

  static Future<void> navigateTo(
      BuildContext context, String groupId, String groupName) {
    return context
        .push(routeName, extra: {"groupId": groupId, "groupName": groupName});
  }

  @override
  GroupChatScreenState createState() => GroupChatScreenState();
}

class GroupChatScreenState extends State<GroupChatScreen> {
  final List<Map<String, dynamic>> messages = [];
  late TextEditingController _controller;
  late WebSocketService webSocketService;
  final String userId = sharedPrefs.userId;
  final String username = sharedPrefs.username;
  int offset = 0;
  final int limit = 40;
  bool isLoading = false;
  ValueNotifier<bool> isTyping = ValueNotifier(false);

  String _lastText = "";

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTyping);

    webSocketService = WebSocketService(
      userId: userId,
      groupId: widget.groupId,
      username: username,
      onMessageReceived: (message) {
        if (message["type"] == "message") {
          setState(() {
            messages.insert(0, message);
          });
        } else if (message["type"] == "typing" &&
            message["sender_id"] != userId) {
          isTyping.value = true;
        } else if (message["type"] == "stop_typing" &&
            message["sender_id"] != userId) {
          isTyping.value = false;
        }
      },
      onTypingStatusChanged: (typing) {
        isTyping.value = typing;
      },
    );

    webSocketService.connect();
    _loadMessages();
  }

  void _onTyping() {
    final currentText = _controller.text;
    if (currentText.isNotEmpty && _lastText.isEmpty) {
      webSocketService.startTyping();
    } else if (currentText.isEmpty && _lastText.isNotEmpty) {
      webSocketService.stopTyping();
    }
    _lastText = currentText;
  }

  Future<void> _loadMessages() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:4000/group-chat/${widget.groupId}/messages?limit=$limit&offset=$offset'),
        headers: {
          'Authorization': 'Bearer ${sharedPrefs.token}',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> newMessages = jsonDecode(response.body);
        setState(() {
          offset += limit;
          messages.addAll(newMessages.map<Map<String, dynamic>>((msg) {
            return {
              "sender_id": msg['sender_id'],
              "username": msg['username'] ?? '',
              "message": msg['message'] ?? '',
            };
          }).toList());
        });
      } else {
        print('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final message = _controller.text;
      webSocketService.sendMessage(message);
      _controller.clear();
      webSocketService
          .stopTyping(); // Assurez-vous d'envoyer stop_typing lorsque le message est envoyé
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    webSocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMessages();
          }
          return false;
        },
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: messages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox.shrink();
                      }
                      final message = messages[index];
                      final isMe = message["sender_id"].toString() == userId;
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.green.shade100
                              : Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isMe ? Colors.green : Colors.blue,
                          ),
                        ),
                        child: ListTile(
                          title: Text(isMe ? "Me" : message["username"]!),
                          subtitle: Text(message["message"]!),
                        ),
                      );
                    },
                  ),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: isTyping,
                  builder: (context, value, child) {
                    if (value) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 8),
                            Text("Someone is typing..."),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
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
          ],
        ),
      ),
    );
  }
}
