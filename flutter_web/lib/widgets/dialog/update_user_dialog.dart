import 'package:flutter/material.dart';
import 'package:flutter_web/models/users.dart';
import 'package:flutter_web/services/users/user_service.dart';

class UpdateUserDialog {
  static void show(BuildContext context, User user, Function() onUserUpdated) {
    final _firstnameController = TextEditingController(text: user.firstName);
    final _lastnameController = TextEditingController(text: user.lastName);
    final _usernameController = TextEditingController(text: user.username);
    final _passwordController =
        TextEditingController(); // Assume no preset for security
    final _phoneController = TextEditingController(text: user.phone);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Update User'),
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
                // TextField(
                //     controller: _passwordController,
                //     decoration: InputDecoration(labelText: 'Password'),
                //     obscureText: true),
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
              child: Text('Update'),
              onPressed: () async {
                try {
                  bool success = await UserService.updateUser(
                    user.id
                        .toString(), // Ensure user ID is correctly handled, as String
                    _firstnameController.text,
                    _lastnameController.text,
                    _usernameController.text,
                    _passwordController.text,
                    _phoneController.text,
                  );
                  if (success) {
                    Navigator.of(dialogContext).pop();
                    onUserUpdated();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('User updated successfully'),
                      backgroundColor: Colors.green,
                    ));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
