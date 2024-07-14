import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_mobile/models/calendar_event.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';

class ParticipationService {
  static Future<Map<DateTime, List<Event>>> fetchParticipations(
      String userId) async {
    if (userId.isEmpty) return {};

    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:4000/users/$userId/group_chat_activity_participations'),
      headers: {
        'Authorization': 'Bearer ${sharedPrefs.token}',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final Map<DateTime, List<Event>> fetchedEvents = {};

      for (var participation in data) {
        final DateTime date =
            DateTime.parse(participation['participation_date']);
        final Event event = Event(
          title: participation['group_chat_name'] ?? 'Group Chat Participation',
          startTime: TimeOfDay.fromDateTime(date),
          endTime: TimeOfDay.fromDateTime(date.add(const Duration(hours: 1))),
        );

        final DateTime eventDate = DateTime(date.year, date.month, date.day);
        if (fetchedEvents[eventDate] == null) {
          fetchedEvents[eventDate] = [event];
        } else {
          fetchedEvents[eventDate]!.add(event);
        }
      }

      return fetchedEvents;
    } else {
      // Handle error
      print('Failed to load participations');
      return {};
    }
  }
}
