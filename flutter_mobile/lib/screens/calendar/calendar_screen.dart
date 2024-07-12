import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_mobile/widgets/navbar.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_mobile/utils/shared_prefs.dart';
import 'dart:convert';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  static String routeName = '/calendar';

  static Future<void> navigateTo(BuildContext context) {
    return context.push(routeName);
  }

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<Event>> selectedEvents;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  final String userId = sharedPrefs.userId;

  @override
  void initState() {
    selectedEvents = {};
    super.initState();
    _fetchParticipations();
  }

  Future<void> _fetchParticipations() async {
    if (userId.isEmpty) return;

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

      setState(() {
        selectedEvents.addAll(fetchedEvents);
      });
    } else {
      // Handle error
      print('Failed to load participations');
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return selectedEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendrier")),
      bottomNavigationBar: const Navbar(),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                this.selectedDay = selectedDay;
                this.focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: _getEventsForDay(selectedDay).length,
              itemBuilder: (context, index) {
                final event = _getEventsForDay(selectedDay)[index];
                return ListTile(
                  title: Text(event.title),
                  subtitle: Text(
                      '${event.startTime.format(context)} - ${event.endTime.format(context)}'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEventDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addEventDialog(BuildContext context) {
    final TextEditingController _eventController = TextEditingController();
    TimeOfDay selectedStartTime = TimeOfDay.now();
    TimeOfDay selectedEndTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _eventController,
                decoration: const InputDecoration(labelText: 'Event Title'),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  TextButton(
                    child: const Text('Start Time'),
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedStartTime,
                      );
                      if (picked != null && picked != selectedStartTime) {
                        setState(() {
                          selectedStartTime = picked;
                        });
                      }
                    },
                  ),
                  Text(selectedStartTime.format(context)),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    child: const Text('End Time'),
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: selectedEndTime,
                      );
                      if (picked != null && picked != selectedEndTime) {
                        setState(() {
                          selectedEndTime = picked;
                        });
                      }
                    },
                  ),
                  Text(selectedEndTime.format(context)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (_eventController.text.isEmpty) return;
                setState(() {
                  final DateTime eventDate = DateTime(
                    selectedDay.year,
                    selectedDay.month,
                    selectedDay.day,
                  );
                  if (selectedEvents[eventDate] != null) {
                    selectedEvents[eventDate]!.add(Event(
                      title: _eventController.text,
                      startTime: selectedStartTime,
                      endTime: selectedEndTime,
                    ));
                  } else {
                    selectedEvents[eventDate] = [
                      Event(
                        title: _eventController.text,
                        startTime: selectedStartTime,
                        endTime: selectedEndTime,
                      )
                    ];
                  }
                });
                Navigator.pop(context);
                _eventController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Event {
  final String title;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  Event({
    required this.title,
    required this.startTime,
    required this.endTime,
  });

  @override
  String toString() => title;
}
