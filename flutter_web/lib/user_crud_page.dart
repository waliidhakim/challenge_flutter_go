import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_web/models/users.dart';
import 'package:flutter_web/services/users/user_service.dart';
import 'package:flutter_web/widgets/dialog/create_user_dialog.dart';
import 'package:flutter_web/widgets/dialog/delete_user_dialog.dart';
import 'package:flutter_web/widgets/dialog/update_user_dialog.dart';
import 'package:flutter_web/widgets/dialog/user_details_dialog.dart';

class UserCrudPage extends StatefulWidget {
  const UserCrudPage({Key? key}) : super(key: key);

  @override
  _UserCrudPageState createState() => _UserCrudPageState();
}

class _UserCrudPageState extends State<UserCrudPage> {
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      _users = await UserService.fetchUsers();
      setState(() {});
    } catch (e) {
      // Gérer l'erreur
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'User Management',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true, // Centrer le titre dans la AppBar
        backgroundColor:
            Colors.lightBlue[100], // Couleur uniforme avec les autres pages
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FloatingActionButton(
                onPressed: () {
                  CreateUserDialog.show(
                      context, _loadUsers); // Passez _loadUsers comme callback
                },
                child: Icon(Icons.add),
                tooltip: 'Create User',
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Avatar')),
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Last Name')),
                  DataColumn(label: Text('First Name')),
                  DataColumn(label: Text('Username')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _users.map((user) => _buildRow(user)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(User user) {
    return DataRow(cells: [
      DataCell(Icon(Icons.person)),
      DataCell(Text(user.id.toString())),
      DataCell(Text(user.lastName)),
      DataCell(Text(user.firstName)),
      DataCell(Text(user.username)),
      DataCell(Text(user.role)),
      DataCell(Text(user.phone)),
      DataCell(Row(
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              UpdateUserDialog.show(context, user, _loadUsers);
            },
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () async {
              try {
                var userDetails = await UserService.fetchUserDetails(user.id);
                UserDetailsDialog.show(context, userDetails);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to load user details: $e')),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              DeleteUserDialog.show(
                context,
                user,
                () {
                  _loadUsers();
                  // Ici, gérer le succès de la suppression
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('User deleted successfully'),
                        backgroundColor: Colors.green),
                  );
                },
                (error) {
                  // Ici, gérer les erreurs
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $error')),
                  );
                },
              );
            },
          ),
        ],
      )),
    ]);
  }
}
