import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart'; // Assurez-vous que le chemin d'accès au package est correct
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile/screens/home/home_screen.dart'; // Assurez-vous que le chemin d'accès au package est correct

class CreateGroupChatScreen extends StatefulWidget {
  const CreateGroupChatScreen({Key? key}) : super(key: key);

  static String routeName = '/createGroupChat';

  static Future<void> navigateTo(BuildContext context) {
    return context.push(routeName);
  }

  @override
  _CreateGroupChatScreenState createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends State<CreateGroupChatScreen> {
  String name = '';
  String catchPhrase = '';
  File? _avatar;
  bool _validate = false;
  String _errorMessage = '';
  final _controller = TextEditingController();

  // Modification ici pour initialiser 'activity' à null
  String? activity; // Modification pour permettre le placeholder
  final List<String> activities = [
    'Sortie',
    'Sport',
    'Randonnée',
    'Balade',
    'Jeux de société',
    'Réunion amicale',
    'Cinéma',
    'Try Hard Challenge',
    'Autre'
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> createGroupChat() async {
    final token =
        sharedPrefs.token; // Récupérer le token depuis les shared preferences

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:4000/group-chat'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['Name'] = name;
    request.fields['Activity'] =
        activity ?? ''; // Gérer le cas où 'activity' est null
    request.fields['CatchPhrase'] = catchPhrase;

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
        _errorMessage = "Les champs ne doivent pas être vides";
      });
    } else if (response.statusCode == 403) {
      // Code pour fonctionnalité désactivée
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Fonctionnalité Désactivée'),
          content: Text(
              'La création de group chat est temporairement désactivée. Veuillez réessayer plus tard.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Ok'),
            ),
          ],
        ),
      );
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
    } else if (response.statusCode == 201) {
      // Cas de succès
      HomeScreen.navigateTo(context);
    } else {
      // Gérer d'autres types de réponses si nécessaire
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erreur'),
          content: Text('Une erreur inconnue est survenue.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Ok'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un nouveau groupe")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) => {name = value},
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: activity,
              decoration: const InputDecoration(
                labelText: 'Activité',
                border: OutlineInputBorder(),
              ),
              hint: const Text(
                  'Choisir le type d\'activité'), // Ajout du placeholder
              items: activities.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  activity = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => {catchPhrase = value},
              decoration: const InputDecoration(
                labelText: 'Phrase d\'accroche',
                border: OutlineInputBorder(),
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
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: createGroupChat,
                child: const Text("Créer le groupe"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
