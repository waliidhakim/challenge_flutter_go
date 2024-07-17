import 'dart:convert';
import 'package:flutter_mobile/models/activity.dart';
import 'package:flutter_mobile/models/settings.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';
import 'package:http/http.dart' as http;

class ActivityService {
  Future<List<Activity>> fetchActivities() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:4000/group-chat-activity'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );

    if (response.statusCode == 200) {
      print(
          "-----------------Success fetching Activities-----------------------");
      List<dynamic> body = jsonDecode(response.body);
      List<Activity> activities =
          body.map((dynamic item) => Activity.fromJson(item)).toList();
      return activities;
    } else {
      throw Exception('Failed to load settings');
    }
  }

  Future<List<Activity>> fetchGroupChatActivities(groupChatId) async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:4000/group-chat-activity/group-chat/$groupChatId/today-participation'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
        },
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Activity> activities =
          body.map((dynamic item) => Activity.fromJson(item)).toList();
      return activities;
    } else {
      throw Exception('Failed to load group chat activity');
    }
  }

  Future<Activity> fetchUserGroupChatActivity(groupChatId) async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:4000/group-chat-activity/group-chat/$groupChatId/my-today-participation'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );

    if (response.statusCode == 200) {
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load group chat activity');
    }
  }

  Future<bool> deleteGroupChatActivity(int id) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:4000/group-chat-activity/$id'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );

    return response.statusCode == 200;
  }

  Future<Activity> createGroupChatActivity(
      int groupChatId, DateTime datetime) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:4000/group-chat-activity'),
        headers: {
          'Authorization': 'Bearer ${sharedPrefs.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'groupChatId': groupChatId,
          'participationDate': datetime.toUtc().toIso8601String(),
        }),
      );
      if (response.statusCode == 200) {
        return Activity.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create group chat activity');
      }
    } catch (e) {
      print('Error creating group chat activity: $e');
      throw Exception('Failed to create group chat activity');
    }
  }
}
