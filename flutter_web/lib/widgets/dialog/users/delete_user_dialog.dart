//

// lib/widgets/dialogs/delete_user_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_web/models/users.dart';
import 'package:flutter_web/services/users/user_service.dart';

class DeleteUserDialog extends StatelessWidget {
  final User user;
  final Function() onDeletionSuccess;
  final Function(String) onDeletionError;

  const DeleteUserDialog({
    Key? key,
    required this.user,
    required this.onDeletionSuccess,
    required this.onDeletionError,
  }) : super(key: key);

  static void show(BuildContext context, User user,
      Function() onDeletionSuccess, Function(String) onDeletionError) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return DeleteUserDialog(
          user: user,
          onDeletionSuccess: () {
            Navigator.of(dialogContext)
                .pop(); // Ferme le dialogue après le succès
            onDeletionSuccess();
          },
          onDeletionError: (error) {
            Navigator.of(dialogContext)
                .pop(); // Ferme le dialogue après une erreur
            onDeletionError(error);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirm Delete'),
      content: Text('Are you sure you want to delete this user?'),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Yes'),
          onPressed: () async {
            try {
              bool deleted = await UserService.deleteUser(user.id);
              if (deleted) {
                onDeletionSuccess();
              }
            } catch (e) {
              onDeletionError(e.toString());
            }
          },
        ),
      ],
    );
  }
}
