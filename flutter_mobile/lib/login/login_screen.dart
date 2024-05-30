import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobile/home/home_screen.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static String routeName = '/login';

  static Future<void> navigateTo(BuildContext context) {
    return Navigator.of(context).pushNamed(routeName);
  }

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isChecked = false;
  String phone = '';
  String password = '';

  Future<void> login(BuildContext context) async {
    debugPrint(phone);
    debugPrint(password);
    final response = await http.post(Uri.parse('http://10.0.2.2:4000/user/login'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8'
    },
    body: jsonEncode({
      'phone': phone.toString(),
      'password': password.toString(),
    }));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account'),
        content: Text(response.body),
        actions: [
          TextButton(
              onPressed: () => HomeScreen.navigateTo(context),
              child: const Text("Ok"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Votre aventure",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              height: 1.2),
                        ),
                        Text(
                          "EventEve",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              height: 1),
                        ),
                        Text(
                          "commence\nmaintenant",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              height: 1.2),
                        ),
                      ],
                    )),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Inscription / Connexion",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Téléphone',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          phone = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        onChanged: (value) {
                          password = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => login(context),
                          child: const Text('S\'inscrire / Se connecter'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
