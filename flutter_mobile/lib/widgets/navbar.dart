import 'package:flutter/material.dart';
import 'package:flutter_mobile/screens/calendar/calendar_screen.dart';
import 'package:flutter_mobile/screens/home/home_screen.dart';
import 'package:flutter_mobile/screens/notifications/notifications_screen.dart';
import 'package:flutter_mobile/screens/settings/settings_screen.dart';
import 'package:go_router/go_router.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            context.push(HomeScreen.routeName);
          case 1:
            context.push(NotificationScreen.routeName);
          case 2:
            context.push(CalendarScreen.routeName);
          case 3:
            context.push(SettingsScreen.routeName);
        }
      },
      selectedIndex: currentPageIndex,
      destinations: const <Widget>[
        NavigationDestination(
          selectedIcon: Icon(Icons.home),
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Badge(label: Text("3"), child: Icon(Icons.notifications_sharp)),
          label: 'Notifications',
        ),
        NavigationDestination(
          icon: Badge(
            label: Text('1'),
            child: Icon(Icons.calendar_today),
          ),
          label: 'Calendrier',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Paramètres',
        ),
      ],
    );
  }
}
