import 'dart:convert';
import 'package:flutter_mobile/models/group_chat.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';
import 'package:http/http.dart' as http;

class GroupChatService {
  Future<List<GroupChat>> fetchGroupChats() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:4000/group-chat'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );

    if (response.statusCode == 200) {
      print(
          "-----------------Success fetching groupChats-----------------------");
      List<dynamic> body = jsonDecode(response.body);
      List<GroupChat> groupChats =
          body.map((dynamic item) => GroupChat.fromJson(item)).toList();
      return groupChats;
    } else {
      throw Exception('Failed to load group chats');
    }
  }

  Future<GroupChat> fetchGroupChatById(String id) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:4000/group-chat/$id'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );

    if (response.statusCode == 200) {
      return GroupChat.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load group chat');
    }
  }

  Future<bool> deleteGroupChat(int id) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:4000/group-chat/$id'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );

    return response.statusCode == 200;
  }
}
