import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobile/main.dart';
import 'package:flutter_mobile/screens/home/home_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_mobile/utils/screen_arguments.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class OnboardScreen extends StatefulWidget {
  final ScreenArguments arguments;

  const OnboardScreen({Key? key, required this.arguments}) : super(key: key);

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
  File? _avatar;

  bool _validate = false;
  String _errorMessage = '';
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  postAccountConfig(String userId) async {
    final token =
        sharedPrefs.token; // Récupérer le token depuis les shared preferences
    final apiUrl = AppSettings().apiUrl;
    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse('$apiUrl/user/$userId'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['Firstname'] = firstname;
    request.fields['Lastname'] = lastname;
    request.fields['Username'] = username;
    request.fields['onboarding'] = 'false';

    if (_avatar != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          _avatar!.path,
          contentType: MediaType('image', 'jpeg'), // ou l'extension appropriée
        ),
      );
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final data = jsonDecode(responseData);

    if (response.statusCode == 400) {
      setState(() {
        _validate = _controller.text.isEmpty;
        _errorMessage = "Le champ ne doit pas être vide";
      });
    } else if (response.statusCode == 500) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: const Text('Erreur de nos services, réessayez plus tard.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Ok"),
            ),
          ],
        ),
      );
      setState(() {
        _validate = false;
      });
    } else {
      // Stocker le username dans les shared preferences
      sharedPrefs.username = data['Username'];
      HomeScreen.navigateTo(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.arguments;
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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              "Renseignez vos informations de profil avant de pouvoir utiliser l'application.",
              style: Theme.of(context).textTheme.bodyLarge,
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
                child: CircleAvatar(
                  maxRadius: 64,
                  backgroundImage: _avatar != null ? FileImage(_avatar!) : null,
                  child: _avatar == null ? Icon(Icons.add_a_photo) : null,
                ),
                onTap: () async {
                  var picked =
                      await FilePicker.platform.pickFiles(type: FileType.image);
                  if (picked != null) {
                    setState(() {
                      _avatar = File(picked.files.first.path!);
                    });
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
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
