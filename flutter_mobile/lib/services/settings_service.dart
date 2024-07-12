import 'dart:convert';
import 'package:flutter_mobile/models/settings.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';
import 'package:http/http.dart' as http;

class SettingsService {
  Future<List<Setting>> fetchGroupChats() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:4000/settings'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );

    if (response.statusCode == 200) {
      print(
          "-----------------Success fetching Settings-----------------------");
      List<dynamic> body = jsonDecode(response.body);
      List<Setting> settings =
          body.map((dynamic item) => Setting.fromJson(item)).toList();
      return settings;
    } else {
      throw Exception('Failed to load settings');
    }
  }

  Future<Setting> fetchUserSettings() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:4000/settings/user'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );

    if (response.statusCode == 200) {
      return Setting.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user settings');
    }
  }

  Future updateSettings(Setting settings) async {
    final response = await http.patch(
      Uri.parse('http://10.0.2.2:4000/settings/user'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "notifyLevel": settings.notifyLevel.name,
        "notifyThreshold": settings.notifyThreshold,
      }),
    );
    return response.statusCode == 200;
  }


  Future<bool> deleteSettings(int id) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:4000/settings/$id'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );

    return response.statusCode == 200;
  }
}
