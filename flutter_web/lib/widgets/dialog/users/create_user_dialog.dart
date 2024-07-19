// lib/widgets/dialogs/create_user_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_web/services/users/user_service.dart';

class CreateUserDialog {
  static void show(BuildContext context, Function onUserCreated) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _firstnameController = TextEditingController();
    final TextEditingController _lastnameController = TextEditingController();
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Create New User'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                      controller: _firstnameController,
                      decoration: InputDecoration(labelText: 'First Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'First Name is required';
                        }
                        return null;
                      }),
                  TextFormField(
                      controller: _lastnameController,
                      decoration: InputDecoration(labelText: 'Last Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Last Name is required';
                        }
                        return null;
                      }),
                  TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username is required';
                        }
                        return null;
                      }),
                  TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      }),
                  TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: 'Phone'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      }),
                ],
              ),
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
                if (_formKey.currentState!.validate()) {
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
                        content: Text('Error while creating user: $e'),
                        backgroundColor: Colors.red));
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
