import 'package:flutter/material.dart';
import 'login_page.dart'; // Assurez-vous d'importer le fichier login_page.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(), // Démarrez l'application sur la page de Login
    );
  }
}
