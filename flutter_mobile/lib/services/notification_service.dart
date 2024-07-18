import 'dart:convert';
import 'package:flutter_mobile/models/notification.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  Future<List<Notif>> fetchNotificationUser(int userID) async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:4000/notifications/$userID'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );

    if (response.statusCode == 200) {
      print("------------Success fetching Notifications-------------------");
      List<dynamic> body = jsonDecode(response.body);
      List<Notif> notifications =
      body.map((dynamic item) => Notif.fromJson(item)).toList();
      return notifications;
    } else {
      print(response.statusCode);
      throw Exception('Failed to load notifications');
    }
  }
}
