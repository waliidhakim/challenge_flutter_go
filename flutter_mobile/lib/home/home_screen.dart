import 'package:flutter/material.dart';
import 'package:flutter_mobile/login/login_screen.dart';
import 'package:flutter_mobile/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  static String routeName = '/home';

  static Future<void> navigateTo(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  // Function to perform API call
  Future<void> callApi() async {

    try {
      final response = await http.get(Uri.parse(
          'http://localhost:4000/user')); // Use IP for Android Emulator
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text('Réponse de l\'API'),
          content: Text(response.body),
        ),
      );
    } catch (e) {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: Text('Erreur lors de la connexion à l\'API: $e'),
        ),
      );
    }
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
            Center(
              child: ElevatedButton(
                onPressed: callApi,
                child: const Text("Appeler l'API"),
              ),
            ),
            ElevatedButton(
              onPressed: () => LoginScreen.navigateTo(context),
              child: const Text('Go!'),
            ),
          ],
        ),
      ),
    );
  }
}