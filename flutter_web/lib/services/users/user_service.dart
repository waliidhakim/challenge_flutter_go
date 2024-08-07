import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_web/models/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static String? apiUrl = dotenv.env['API_URL'];

  static Future<List<User>> fetchUsers({int page = 1, int limit = 3}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');
    if (token != null && token.startsWith('"') && token.endsWith('"')) {
      token = token.substring(1, token.length - 1); // Supprime les guillemets
    }

    final response = await http.get(
      Uri.parse('$apiUrl/user?page=$page&limit=$limit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
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
    String? apiUrl = dotenv.env['API_URL'];
    final response = await http.delete(
      Uri.parse('$apiUrl/user/$id'),
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

  static Future<Map<String, dynamic>> fetchUserDetails(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');
    String? apiUrl = dotenv.env['API_URL'];
    final response = await http.get(
      Uri.parse('$apiUrl/user/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      var userData = json.decode(response.body);
      return userData;
    } else {
      throw Exception('Failed to load user details');
    }
  }

  static Future<bool> createUser(
    String firstname,
    String lastname,
    String username,
    String password,
    String phone,
  ) async {
    String? apiUrl = dotenv.env['API_URL'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');
    final response = await http.post(
      Uri.parse('$apiUrl/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
      body: jsonEncode({
        'Firstname': firstname,
        'Lastname': lastname,
        'Username': username,
        'Password': password,
        'Phone': phone,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  static Future<bool> updateUser(
    String id,
    String firstname,
    String lastname,
    String username,
    String password,
    String phone,
  ) async {
    String? apiUrl = dotenv.env['API_URL'];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');
    if (token != null && token.startsWith('"') && token.endsWith('"')) {
      token = token.substring(1, token.length - 1); // Supprime les guillemets
    }
    final response = await http.patch(
      Uri.parse('$apiUrl/user/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
      body: jsonEncode({
        'Firstname': firstname,
        'Lastname': lastname,
        'Username': username,
        'Password': password,
        'Phone': phone,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<Map<String, dynamic>> fetchUserStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');

    if (token != null && token.startsWith('"') && token.endsWith('"')) {
      token = token.substring(1, token.length - 1); // Supprime les guillemets
    }
    final response = await http.get(
      Uri.parse('$apiUrl/users/stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user stats');
    }
  }
}
