import 'dart:convert';
// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_web/models/users.dart';
import 'package:flutter_web/services/users/user_service.dart';
import 'package:flutter_web/widgets/dialog/delete_user_dialog.dart';
// import 'package:flutter_web/utlis/js_cookies.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      // Gérer l'erreur ici
    }
  }

  // Future<void> _fetchUsers() async {
  //   final response = await http.get(Uri.parse('http://localhost:4000/user'));
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       _users = (json.decode(response.body) as List)
  //           .map((data) => User.fromJson(data))
  //           .toList();
  //     });
  //   } else {
  //     throw Exception('Failed to load users');
  //   }
  // }

  // ----------
  void _showDeleteDialog(User user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this user?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                try {
                  bool deleted = await UserService.deleteUser(user.id);
                  if (deleted) {
                    setState(() {
                      _users.removeWhere((u) => u.id == user.id);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('User deleted successfully'),
                      backgroundColor: Colors.green,
                    ));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(e.toString()),
                  ));
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');
    if (token != null && token.startsWith('"') && token.endsWith('"')) {
      token = token.substring(1, token.length - 1); // Supprime les guillemets
    }

    print("token : ${token}");
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication token not found')));
      return;
    }

    final response = await http.delete(
      Uri.parse('http://localhost:4000/user/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _users.removeWhere((user) =>
            user.id == id); // Mise à jour de l'état pour retirer l'utilisateur
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('User deleted successfully'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ));
    } else {
      // Gérer l'erreur, par exemple montrer un message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Failed to delete user, status code: ${response.statusCode}')));
    }
  }

  Future<void> _showUserDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:4000/user/$id'),
        headers: {
          'Content-Type': 'application/json',
          // Ajoutez des en-têtes supplémentaires si nécessaire, comme l'Authorization
        },
      );
      if (response.statusCode == 200) {
        var userData = json.decode(response.body);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Details for user with id : ${userData['ID']}'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      'Firstname: ${userData['Firstname']}',
                    ),
                    Text('Lastname: ${userData['Lastname']}'),
                    // Ajoutez d'autres détails que vous voulez montrer
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load user details')));
    }
  }

  Future<void> _showCreateUserDialog() async {
    final _firstnameController = TextEditingController();
    final _lastnameController = TextEditingController();
    final _usernameController = TextEditingController();
    final _passwordController = TextEditingController();
    final _phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _createUser(
                  _firstnameController.text,
                  _lastnameController.text,
                  _usernameController.text,
                  _passwordController.text,
                  _phoneController.text,
                );
                _firstnameController.dispose();
                _lastnameController.dispose();
                _usernameController.dispose();
                _passwordController.dispose();
                _phoneController.dispose();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _createUser(String firstname, String lastname, String username,
      String password, String phone) async {
    final response = await http.post(
      Uri.parse('http://localhost:4000/user'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'Firstname': firstname,
        'Lastname': lastname,
        'Username': username,
        'Password': password,
        'Phone': phone,
      }),
    );

    if (response.statusCode == 201) {
      _loadUsers(); // Refresh the list
      //Navigator.of(context).pop(); // Close the dialog if open
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('User created successfully'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to create user: ${response.body}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  // ---------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: _showCreateUserDialog,
                child: Text('Create User'),
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
              // Mise à jour de l'utilisateur
            },
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              _showUserDetails(user
                  .id); // Assurez-vous que vous avez un identifiant pour chaque utilisateur
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
