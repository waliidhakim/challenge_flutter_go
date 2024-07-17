import 'dart:convert';
import 'package:flutter_mobile/models/activity.dart';
import 'package:flutter_mobile/models/location.dart';
import 'package:flutter_mobile/models/settings.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';
import 'package:http/http.dart' as http;

class LocationService {
  Future<List<Location>> fetchGroupLocations(int groupChatId) async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:4000/group-chat-activity-location/group-chat/$groupChatId'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );

    if (response.statusCode == 200) {
      print("------------Success fetching Locations-------------------");
      List<dynamic> body = jsonDecode(response.body);
      List<Location> locations =
          body.map((dynamic item) => Location.fromJson(item)).toList();
      return locations;
    } else {
      throw Exception('Failed to load locations');
    }
  }
}
