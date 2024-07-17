import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FeatureService {
  static String? baseUrl = dotenv.env['API_URL'];

  // Méthode pour récupérer toutes les fonctionnalités
  static Future<List<dynamic>> fetchFeatures() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');

    final response = await http.get(
      Uri.parse('$baseUrl/features'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    } else {
      throw Exception('Failed to load features');
    }
  }

  // Méthode pour mettre à jour une fonctionnalité
  static Future<void> updateFeature(int id, bool isActive) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');

    final response = await http.patch(
      Uri.parse('$baseUrl/features/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
      body: jsonEncode({'IsActive': isActive}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update feature');
    }
  }

  static Future<bool> createFeature(String featureName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');

    final response = await http.post(
      Uri.parse('$baseUrl/features'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
      body: jsonEncode({'FeatureName': featureName, 'IsActive': true}),
    );
    return response.statusCode == 201;
  }

  static Future<bool> deleteFeature(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');

    final response = await http.delete(
      Uri.parse('$baseUrl/features/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
    );
    return response.statusCode == 200;
  }
}
