import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_mobile/screens/home/home_screen.dart';

class EditGroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupActivity;
  final String groupCatchPhrase;
  final String imageUrl;

  const EditGroupChatScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.groupActivity,
    required this.groupCatchPhrase,
    required this.imageUrl,
  }) : super(key: key);

  static String routeName = '/editGroupChat';

  static Future<void> navigateTo(
      BuildContext context,
      String groupId,
      String groupName,
      String groupActivity,
      String groupCatchPhrase,
      String imageUrl) {
    return context.push(
      routeName,
      extra: {
        "groupId": groupId,
        "groupName": groupName,
        "groupActivity": groupActivity,
        "groupCatchPhrase": groupCatchPhrase,
        "imageUrl": imageUrl,
      },
    );
  }

  @override
  _EditGroupChatScreenState createState() => _EditGroupChatScreenState();
}

class _EditGroupChatScreenState extends State<EditGroupChatScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _activityController;
  late TextEditingController _catchPhraseController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.groupName);
    _activityController = TextEditingController(text: widget.groupActivity);
    _catchPhraseController =
        TextEditingController(text: widget.groupCatchPhrase);
  }

  Future<void> _updateGroupChat() async {
    if (_formKey.currentState!.validate()) {
      final token = sharedPrefs.token;
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('http://10.0.2.2:4000/group-chat/infos/${widget.groupId}'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = _nameController.text;
      request.fields['activity'] = _activityController.text;
      request.fields['catchPhrase'] = _catchPhraseController.text;

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _imageFile!.path,
            contentType:
                MediaType('image', 'jpeg'), // ou l'extension appropriée
          ),
        );
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);

      if (response.statusCode == 400) {
        setState(() {
          _formKey.currentState!.validate();
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
                child: const Text("Ok"),
              ),
            ],
          ),
        );
      } else {
        HomeScreen.navigateTo(context);
      }
    }
  }

  Future<void> _pickImage() async {
    var picked = await FilePicker.platform.pickFiles(type: FileType.image);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.files.first.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Group Chat')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _activityController,
                decoration: const InputDecoration(labelText: 'Activity'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an activity';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _catchPhraseController,
                decoration: const InputDecoration(labelText: 'Catch Phrase'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a catch phrase';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (widget.imageUrl.isNotEmpty)
                Image.network(
                  widget.imageUrl,
                  height: 100,
                  width: 100,
                ),
              if (_imageFile != null)
                Image.file(
                  _imageFile!,
                  height: 100,
                  width: 100,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateGroupChat,
                child: const Text('Update Group Chat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
