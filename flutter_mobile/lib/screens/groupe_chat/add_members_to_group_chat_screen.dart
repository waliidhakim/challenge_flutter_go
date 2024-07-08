import 'package:flutter/material.dart';
import 'package:flutter_mobile/services/groupe_chat_service.dart';
import 'package:go_router/go_router.dart';

class AddMembersScreen extends StatefulWidget {
  final String groupChatId;

  const AddMembersScreen({Key? key, required this.groupChatId})
      : super(key: key);

  static String routeName = '/add_members';
  static void navigateTo(BuildContext context, String groupChatId) {
    GoRouter.of(context).push('/add_members', extra: groupChatId);
  }

  @override
  _AddMembersScreenState createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _members = [];

  void _addMemberField() {
    setState(() {
      _members.add('');
    });
  }

  void _removeMemberField(int index) {
    setState(() {
      _members.removeAt(index);
    });
  }

  void _onMemberPhoneChanged(int index, String value) {
    _members[index] = value;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final response =
          await GroupChatService().addMembers(widget.groupChatId, _members);
      if (response) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Members added successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add members')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter des membres")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                                labelText: 'Numéro de téléphone'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un numéro de téléphone';
                              }
                              return null;
                            },
                            onChanged: (value) =>
                                _onMemberPhoneChanged(index, value),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove_circle),
                          onPressed: () => _removeMemberField(index),
                        ),
                      ],
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _addMemberField,
                child: const Text('Ajouter un membre'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Soumettre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
