import 'dart:convert';
import 'package:flutter_mobile/main.dart';
import 'package:flutter_mobile/models/notification.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  Future<List<Notif>> fetchNotificationUser(int userID) async {
    final apiUrl = AppSettings().apiUrl;
    final response = await http.get(
      Uri.parse(
          '$apiUrl/notifications/$userID'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );

    if (response.statusCode == 200) {
      print("------------Success fetching Notifications-------------------");
      List<dynamic> body = jsonDecode(response.body);
      List<Notif> notifications =
      body.map((dynamic item) => Notif.fromJson(item)).toList();
      print(notifications);
      return notifications;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load notifications');
    }
  }
}
