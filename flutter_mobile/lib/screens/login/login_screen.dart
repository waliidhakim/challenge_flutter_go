import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobile/screens/home/home_screen.dart';
import 'package:flutter_mobile/screens/onboard/onboard_screen.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';
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
  final _controller = TextEditingController();
  bool _validate = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> register(BuildContext context) async {
    final response =
    await http.post(Uri.parse('http://10.0.2.2:4000/user'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'phone': phone.toString(),
          'password': password.toString(),
        }));
    final data = jsonDecode(response.body);
    if (response.statusCode == 400) {
      setState(() {
        _validate = true;
        _errorMessage = "Compte existant avec ce téléphone";
      });
    } else if (response.statusCode == 500) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erreur'),
            content: const Text('Erreur de nos service, réessayez plus tard.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Ok"))
            ],
          )
      );
      setState(() {
        _validate = false;
      });
    } else {
      try {
        final token = await apiLogin();
        sharedPrefs.token = token;
        OnboardScreen.navigateTo(context, data["ID"].toString());
      } catch(e) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Erreur'),
              content: const Text('Erreur de nos service, réessayez plus tard.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Ok"))
              ],
            )
        );
      }
    }
  }

  Future<String> apiLogin() async {
    try {
      final response =
      await http.post(Uri.parse('http://10.0.2.2:4000/user/login'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'phone': phone.toString(),
            'password': password.toString(),
          }));
      final data = jsonDecode(response.body);
      final token = data['token'];
      if (response.statusCode != 200) {
       throw("Error when logging in");
      }
      return token;
    } catch(e) {
      return '';
    }
  }

  Future<void> login(BuildContext context) async {
    final response =
        await http.post(Uri.parse('http://10.0.2.2:4000/user/login'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'phone': phone.toString(),
              'password': password.toString(),
            }));
    final data = jsonDecode(response.body);
    if (response.statusCode == 400) {
      setState(() {
        _validate = true;
        _errorMessage = "Mauvais téléphone";
      });
    } else if (response.statusCode == 500) {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text('Erreur'),
          content: Text('Erreur de nos service, réessayez plus tard'),
        )
      );
      setState(() {
        _validate = false;
      });
    } else {
      sharedPrefs.token = data['token'];
      HomeScreen.navigateTo(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "EventEve",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              height: 1),
                        ),
                      ],
                    )),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
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
                        controller: _controller,
                        decoration: InputDecoration(
                          labelText: 'Téléphone',
                          border: const OutlineInputBorder(),
                          errorText: _validate ? _errorMessage : null,
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          phone = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          errorText: _validate ? "Mauvais mot de passe" : null,
                        ),
                        obscureText: true,
                        onChanged: (value) {
                          password = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => register(context),
                              child: const Text('S\'inscrire'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => login(context),
                              child: const Text('Se connecter'),
                            ),
                          ),
                        ],
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
