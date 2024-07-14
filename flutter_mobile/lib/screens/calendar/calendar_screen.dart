import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/calendar_event.dart';
import 'package:flutter_mobile/utils/calendar_utils.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_mobile/widgets/navbar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';

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
    final fetchedEvents =
        await ParticipationService.fetchParticipations(userId);
    setState(() {
      selectedEvents.addAll(fetchedEvents);
    });
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
    );
  }
}
