import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web/models/log_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LogService {
  static String? apiUrl = dotenv.env['API_URL'];

  Future<Map<String, dynamic>> fetchLogs(
      {int page = 1, String? logLevel}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');
    final response = await http.get(
      logLevel != null
          ? Uri.parse('$apiUrl/logs/level/$logLevel?page=$page')
          : Uri.parse('$apiUrl/logs?page=$page'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> logsJson = data['logs'];
      List<Log> logs = logsJson.map((json) => Log.fromJson(json)).toList();
      return {
        'logs': logs,
        'currentPage': data['currentPage'],
        'totalPages': data['totalPages']
      };
    } else {
      throw Exception('Failed to load logs');
    }
  }
}