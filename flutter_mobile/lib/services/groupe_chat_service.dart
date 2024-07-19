import 'dart:convert';
import 'package:flutter_mobile/main.dart';
import 'package:flutter_mobile/models/group_chat.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';
import 'package:http/http.dart' as http;

class GroupChatService {
  Future<List<GroupChat>> fetchGroupChats() async {
    final apiUrl = AppSettings().apiUrl;
    final response = await http.get(
      Uri.parse('$apiUrl/group-chat'),
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
    final apiUrl = AppSettings().apiUrl;
    final response = await http.get(
      Uri.parse('$apiUrl/group-chat/$id'),
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
    final apiUrl = AppSettings().apiUrl;
    final response = await http.delete(
      Uri.parse('$apiUrl/group-chat/$id'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );

    return response.statusCode == 200;
  }

  Future<bool> addMembers(String groupChatId, List<String> members) async {
    final apiUrl = AppSettings().apiUrl;
    final response = await http.patch(
      Uri.parse('$apiUrl/group-chat/$groupChatId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
      body: jsonEncode({
        'new_members': members,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<Map<String, int>> fetchUnreadMessages() async {
    final apiUrl = AppSettings().apiUrl;
    final response = await http.get(
      Uri.parse('$apiUrl/unread-messages'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return Map.fromIterable(body,
          key: (item) => item['group_chat_id'].toString(),
          value: (item) => item['count']);
    } else {
      throw Exception('Failed to load unread messages');
    }
  }

  Future<bool> updateGroupChat(
      String groupId, String name, String activity, String catchPhrase,
      [String? imagePath]) async {
    try {
      final apiUrl = AppSettings().apiUrl;
      var uri = Uri.parse('$apiUrl/group-chat/infos/$groupId');
      var request = http.MultipartRequest('PATCH', uri)
        ..headers['Authorization'] = 'Bearer ${sharedPrefs.token}'
        ..fields['name'] = name
        ..fields['activity'] = activity
        ..fields['catchPhrase'] = catchPhrase;

      if (imagePath != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', imagePath));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update group chat: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error updating group chat: $e');
      return false;
    }
  }
}
