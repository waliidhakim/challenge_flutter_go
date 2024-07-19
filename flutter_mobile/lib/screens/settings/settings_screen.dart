import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/settings.dart';
import 'package:flutter_mobile/screens/home/notifications/notification_selection.dart';
import 'package:flutter_mobile/screens/login/login_screen.dart';
import 'package:flutter_mobile/services/settings_service.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';
import 'package:flutter_mobile/widgets/navbar.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static String routeName = '/settings';

  static Future<void> navigateTo(BuildContext context) {
    return context.push(routeName);
  }

  handleChange(Setting settings) {
    SettingsService().updateSettings(settings);
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
              NotificationSelection(
                onChange: handleChange,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  sharedPrefs.token = "";
                  LoginScreen.navigateTo(context);
                },
                child: const Text('Logout'),
                // Red danger button using Material theme of context
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
