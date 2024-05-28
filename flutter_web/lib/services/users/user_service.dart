import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_web/models/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static Future<List<User>> fetchUsers() async {
    final response = await http.get(Uri.parse('http://localhost:4000/user'));

    if (response.statusCode == 200) {
      List<User> users = (json.decode(response.body) as List)
          .map((data) => User.fromJson(data))
          .toList();
      return users;
    } else {
      throw Exception('Failed to load users');
    }
  }

  static Future<bool> deleteUser(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');
    if (token != null && token.startsWith('"') && token.endsWith('"')) {
      token = token.substring(1, token.length - 1); // Supprime les guillemets
    }

    if (token == null) {
      return false;
    }

    final response = await http.delete(
      Uri.parse('http://localhost:4000/user/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
          'Failed to delete user, status code: ${response.statusCode}');
    }
  }
}
