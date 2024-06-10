import 'package:flutter/material.dart';
import 'package:flutter_mobile/screens/login/login_screen.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  static String routeName = '/home';

  static Future<void> navigateTo(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }
  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(title: const Text("Tester la Connexion API")),
        body: Column(
          children: [
            ElevatedButton(
              onPressed: () => {
                sharedPrefs.token = "",
                LoginScreen.navigateTo(context)
              },
              child: const Text('Logout'),
            ),
            Text(sharedPrefs.token),
          ],
        ),
      ),
    );
  }
}