import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Function to perform API call
  Future<void> callApi() async {
    try {
      final response = await http.get(
          Uri.parse('http://10.0.2.2:4000')); // Use IP for Android Emulator
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
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(title: const Text("Tester la Connexion API")),
        body: Center(
          child: ElevatedButton(
            onPressed: callApi,
            child: const Text("Appeler l'API"),
          ),
        ),
      ),
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
