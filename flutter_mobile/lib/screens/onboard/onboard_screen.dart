import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobile/screens/home/home_screen.dart';
import 'package:flutter_mobile/screens/login/login_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class ScreenArguments {
  final String userId;

  ScreenArguments(this.userId);
}


class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  static String routeName = '/onboard';

  static navigateTo(BuildContext context, userId) {
    Navigator.pushNamed(
      context,
      routeName,
      arguments: ScreenArguments(userId),
    );
  }

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  String firstname = '';
  String lastname = '';
  String username = '';

  bool _validate = false;
  String _errorMessage = '';
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  postAccountConfig(userId) async {
    final response = await http.patch(
        Uri.parse('http://10.0.2.2:4000/user/$userId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'firstname': firstname.toString(),
          'lastname': lastname.toString(),
          'username': username.toString(),
          'onboarding': false,
        }));
    final data = jsonDecode(response.body);
    if (response.statusCode == 400) {
      setState(() {
        _validate = _controller.text.isEmpty;
        _errorMessage = "Le champ ne doit pas être vide";
      });
    } else if (response.statusCode == 500) {
      showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: const Text('Erreur'),
                content:
                const Text('Erreur de nos service, réessayez plus tard.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text("Ok"))
                ],
              ));
      setState(() {
        _validate = false;
      });
    } else {
      HomeScreen.navigateTo(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute
        .of(context)!
        .settings
        .arguments as ScreenArguments;
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Votre compte a bien été créé !",
              style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              "Renseignez vos informations de profil avant de pouvoir utiliser l'application.",
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => {firstname = value},
              decoration: const InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(),
                errorText: false ? "Mauvais mot de passe" : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => {lastname = value},
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
                errorText: false ? "Mauvais mot de passe" : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => {username = value},
              decoration: const InputDecoration(
                labelText: "Nom d'utilisateur",
                border: OutlineInputBorder(),
                errorText: false ? "Mauvais mot de passe" : null,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: GestureDetector(
                child: const CircleAvatar(
                  maxRadius: 64,
                  child: Icon(Icons.add_a_photo),
                ),
                onTap: () async {
                  var picked =
                  await FilePicker.platform.pickFiles(type: FileType.image);
                  if (picked != null) {
                    print(picked.files.first.name);
                  }
                },
              ),
            ),
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: FilledButton(
                              onPressed: () => postAccountConfig(args.userId),
                              child: const Text("Finaliser votre compte"),
                            ))
                      ],
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
