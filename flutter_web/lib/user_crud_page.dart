import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_web/models/users.dart';
import 'package:flutter_web/services/users/user_service.dart';
import 'package:flutter_web/widgets/dialog/users/create_user_dialog.dart';
import 'package:flutter_web/widgets/dialog/users/delete_user_dialog.dart';
import 'package:flutter_web/widgets/dialog/users/update_user_dialog.dart';
import 'package:flutter_web/widgets/dialog/users/user_details_dialog.dart';

class UserCrudPage extends StatefulWidget {
  const UserCrudPage({Key? key}) : super(key: key);

  @override
  _UserCrudPageState createState() => _UserCrudPageState();
}

class _UserCrudPageState extends State<UserCrudPage> {
  List<User> _users = [];
  int _currentPage = 1;
  final int _limit = 3;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      _users = await UserService.fetchUsers(page: _currentPage, limit: _limit);
      setState(() {});
    } catch (e) {
      // Gérer l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
    }
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
    });
    _loadUsers();
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _loadUsers();
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _previousPage,
                child: Text('Previous'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: _nextPage,
                child: Text('Next'),
              ),
            ],
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
      DataCell(
        user.avatarUrl != null && user.avatarUrl.isNotEmpty
            ? Image.network(
                user.avatarUrl,
                width: 50, // Taille de l'image
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  // Si le chargement échoue, retourner une icône par défaut
                  return Icon(Icons.person, size: 50);
                },
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              )
            : Icon(Icons.person, size: 50), // Si aucune URL n'est fournie
      ),
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
