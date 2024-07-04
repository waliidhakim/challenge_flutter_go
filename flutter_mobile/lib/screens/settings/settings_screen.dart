import 'package:flutter/material.dart';
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
    );
  }
}
