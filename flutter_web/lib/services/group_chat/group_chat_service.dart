import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_web/models/group_chat.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupChatService {
  static String? apiUrl = dotenv.env['API_URL'];
  static Future<List<GroupChat>> fetchGroupChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');

    if (token != null && token.startsWith('"') && token.endsWith('"')) {
      token = token.substring(1, token.length - 1); // Supprime les guillemets
    }

    final response = await http.get(
      Uri.parse("$apiUrl/group-chat"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      List<GroupChat> groupChats = (json.decode(response.body) as List)
          .map((data) => GroupChat.fromJson(data))
          .toList();
      return groupChats;
    } else {
      throw Exception('Failed to load group chats');
    }
  }

  // Ajoutez d'autres méthodes CRUD ici si nécessaire

  static Future<Map<String, dynamic>> fetchGroupChatDetails(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');
    final response = await http.get(
      Uri.parse('$apiUrl/group-chat/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load group chat details');
    }
  }

  static Future<void> updateGroupChat(int id, Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');
    final response = await http.patch(
      Uri.parse('http://localhost:4000/group-chat/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update group chat');
    }
  }
}
