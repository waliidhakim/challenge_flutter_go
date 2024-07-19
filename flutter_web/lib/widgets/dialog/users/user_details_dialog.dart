// lib/widgets/dialogs/user_details_dialog.dart
import 'package:flutter/material.dart';

class UserDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserDetailsDialog({Key? key, required this.userData}) : super(key: key);

  static void show(BuildContext context, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UserDetailsDialog(userData: userData);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Details for user with id : ${userData['ID']}'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Firstname: ${userData['Firstname']}'),
            Text('Lastname: ${userData['Lastname']}'),
            // Ajoutez d'autres détails que vous voulez montrer
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
