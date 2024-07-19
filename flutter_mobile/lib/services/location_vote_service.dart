import 'dart:convert';
import 'package:flutter_mobile/main.dart';
import 'package:flutter_mobile/models/activity.dart';
import 'package:flutter_mobile/models/location.dart';
import 'package:flutter_mobile/models/location_vote.dart';
import 'package:flutter_mobile/models/settings.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';
import 'package:http/http.dart' as http;

class LocationVoteService {
  Future<List<LocationVote>> fetchGroupLocationVotes(int groupChatId) async {
    final apiUrl = AppSettings().apiUrl;
    final response = await http.get(
      Uri.parse('$apiUrl/group-chat-activity-location-vote/group-chat/$groupChatId/today'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );

    if (response.statusCode == 200) {
      print("------------Success fetching Locations votes-------------------");
      List<dynamic> body = jsonDecode(response.body);
      List<LocationVote> locations = body.map((dynamic item) => LocationVote.fromJson(item)).toList();
      return locations;
    } else {
      throw Exception('Failed to load locations votes');
    }
  }

  Future<void> deleteVote(int locationId) async {
    final apiUrl = AppSettings().apiUrl;
    final response = await http.delete(
      Uri.parse('$apiUrl/group-chat-activity-location-vote/user-location/$locationId/today'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );
  }

  Future<void> deleteVoteInGroup(int groupId) async {
    final apiUrl = AppSettings().apiUrl;
    final response = await http.delete(
      Uri.parse('$apiUrl/group-chat-activity-location-vote/user-location/group/$groupId/today'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );
    if (response.statusCode != 200) {
      print(response.statusCode);
      throw Exception('Failed to delete vote');
    }
  }

  Future<LocationVote> createVote(int locationId, int groupId) async {
    final apiUrl = AppSettings().apiUrl;
    final response = await http.post(Uri.parse('$apiUrl/group-chat-activity-location-vote'),
        headers: {
          'Authorization': 'Bearer ${sharedPrefs.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'LocationId': locationId,
          'VoteDate': DateTime.now().toUtc().toIso8601String(),
          'Groupid': groupId,
        }));
    if (response.statusCode == 201) {
      return LocationVote.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create vote');
    }
  }
}
