// lib/widgets/dialogs/create_user_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_web/services/users/user_service.dart';

class CreateUserDialog {
  static void show(BuildContext context, Function onUserCreated) {
    final _firstnameController = TextEditingController();
    final _lastnameController = TextEditingController();
    final _usernameController = TextEditingController();
    final _passwordController = TextEditingController();
    final _phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Create New User'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                    controller: _firstnameController,
                    decoration: InputDecoration(labelText: 'First Name')),
                TextField(
                    controller: _lastnameController,
                    decoration: InputDecoration(labelText: 'Last Name')),
                TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username')),
                TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true),
                TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(labelText: 'Phone')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () async {
                try {
                  bool success = await UserService.createUser(
                    _firstnameController.text,
                    _lastnameController.text,
                    _usernameController.text,
                    _passwordController.text,
                    _phoneController.text,
                  );
                  if (success) {
                    Navigator.of(dialogContext).pop(); // Ferme le dialogue
                    onUserCreated(); // Appelle la fonction de rappel
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('User created successfully'),
                      backgroundColor: Colors.green,
                    ));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(
                      content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
