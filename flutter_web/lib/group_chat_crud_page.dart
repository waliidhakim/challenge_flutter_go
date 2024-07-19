import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_web/models/group_chat.dart';
import 'package:flutter_web/services/group_chat/group_chat_service.dart';
import 'package:flutter_web/widgets/dialog/group_chat/group_chat_details_dialog.dart';
import 'package:flutter_web/widgets/dialog/group_chat/group_chat_update_dialog.dart';

class GroupChatCrudPage extends StatefulWidget {
  const GroupChatCrudPage({Key? key}) : super(key: key);

  @override
  _GroupChatCrudPageState createState() => _GroupChatCrudPageState();
}

class _GroupChatCrudPageState extends State<GroupChatCrudPage> {
  List<GroupChat> _groupChats = [];

  @override
  void initState() {
    super.initState();
    _loadGroupChats();
  }

  Future<void> _loadGroupChats() async {
    try {
      _groupChats = await GroupChatService.fetchGroupChats();
      setState(() {});
    } catch (e) {
      // Gérer l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load group chats: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Group Chat Management',
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
                  // Action pour créer un nouveau GroupChat
                },
                child: Icon(Icons.add),
                tooltip: 'Create Group Chat',
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => {},
                child: Text('Previous'),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () => {},
                child: Text('Next'),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Activity')),
                  DataColumn(label: Text('Catch Phrase')),
                  DataColumn(label: Text('Image')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _groupChats
                    .map((groupChat) => _buildRow(groupChat))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildRow(GroupChat groupChat) {
    return DataRow(cells: [
      DataCell(Text(groupChat.id.toString())),
      DataCell(Text(groupChat.name)),
      DataCell(Text(groupChat.activity)),
      DataCell(Text(groupChat.catchPhrase)),
      DataCell(
        groupChat.imageUrl != null && groupChat.imageUrl.isNotEmpty
            ? Image.network(
                groupChat.imageUrl,
                width: 50, // Taille de l'image
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  // Si le chargement échoue, retourner une icône par défaut
                  return Icon(Icons.image, size: 50);
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
            : Icon(Icons.image, size: 50), // Si aucune URL n'est fournie
      ),
      DataCell(Row(
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              try {
                var groupChatDetails =
                    await GroupChatService.fetchGroupChatDetails(groupChat.id);
                UpdateGroupChatDialog.show(
                    context, groupChatDetails, _loadGroupChats);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Failed to load group chat details: $e')),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () async {
              try {
                var groupChatDetails =
                    await GroupChatService.fetchGroupChatDetails(groupChat.id);
                GroupChatDetailsDialog.show(context, groupChatDetails);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Failed to load group chat details: $e')),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Action pour supprimer le GroupChat
            },
          ),
        ],
      )),
    ]);
  }
}
