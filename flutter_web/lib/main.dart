import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = "Appuyez sur le bouton pour tester l'API";

  Future<void> callApi() async {
    var url = Uri.http('localhost:8081', '/test');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        _message = 'Succès : ${response.body}';
      });
    } else {
      setState(() {
        _message = 'Échec de l\'API avec le code : ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Test de Connexion API")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_message,
                  style: const TextStyle(fontSize: 16, color: Colors.black)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: callApi,
                child: const Text("Tester l'API Go"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
