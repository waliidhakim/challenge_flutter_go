import 'package:flutter/material.dart';
import 'package:flutter_mobile/screens/home/notifications/notification_selection.dart';
import 'package:flutter_mobile/widgets/navbar.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static String routeName = '/settings';

  static Future<void> navigateTo(BuildContext context) {
    return context.push(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres")),
      bottomNavigationBar: const Navbar(),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notifications",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              const NotificationSelection(),
            ],
          ),
        ),
      ),
    );
  }
}
