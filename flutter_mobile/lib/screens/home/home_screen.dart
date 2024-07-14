import 'package:flutter/material.dart';
import 'package:flutter_mobile/screens/debug/debud_prefs_screen.dart';
import 'package:flutter_mobile/screens/groupe_chat/add_members_to_group_chat_screen.dart';
import 'package:flutter_mobile/screens/groupe_chat/create_group_chat_screen.dart';
import 'package:flutter_mobile/screens/groupe_chat/edit_group_chat_screen.dart';
import 'package:flutter_mobile/screens/groupe_chat/group_chat_detail_screen.dart';
import 'package:flutter_mobile/screens/groupe_chat/group_chat_screen.dart';
import 'package:flutter_mobile/widgets/long_press_item.dart';
import 'package:flutter_mobile/widgets/navbar.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile/screens/login/login_screen.dart';
import 'package:flutter_mobile/services/groupe_chat_service.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';
import 'package:flutter_mobile/models/group_chat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static String routeName = '/home';

  static Future<void> navigateTo(BuildContext context) {
    return context.push(routeName);
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<GroupChat>> groupChats;
  // late Future<Map<String, int>> unreadMessages;

  @override
  void initState() {
    super.initState();
    groupChats = GroupChatService().fetchGroupChats();
    // unreadMessages = GroupChatService().fetchUnreadMessages();
  }

  void _showPopupMenu(BuildContext context, GroupChat group) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    // Détermine si l'utilisateur actuel est le propriétaire du groupe
    print('Checking ownership for user ID: ${sharedPrefs.userId}');
    bool isOwner = group.isUserOwner(sharedPrefs.userId);

    final List<PopupMenuEntry<String>> menuItems = [
      const PopupMenuItem<String>(
        value: 'details',
        child: Text('Afficher les détails'),
      ),
    ];

    if (isOwner) {
      menuItems.addAll([
        const PopupMenuItem<String>(
          value: 'edit',
          child: Text('Modifier'),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Text('Supprimer'),
        ),
        const PopupMenuItem<String>(
          value: 'add_members',
          child: Text('Ajouter des membres'),
        ),
      ]);
    }

    final result = await showMenu(
      context: context,
      position: RelativeRect.fromRect(
          Offset.zero & const Size(40, 40), // Position arbitraire
          Offset.zero & overlay.size),
      items: menuItems,
    );

    if (result != null) {
      switch (result) {
        case 'details':
          GroupChatDetailScreen.navigateTo(context, group.id.toString());
          break;
        case 'edit':
          EditGroupChatScreen.navigateTo(context, group.id.toString(),
              group.name, group.activity, group.catchPhrase, group.imageUrl);
          break;
        case 'delete':
          _deleteGroupChat(context, group.id);
          break;
        case 'add_members':
          String groupId = group.id.toString();
          print(
              "--------------------Redirect to add_members page of the group $groupId----------------------------");
          AddMembersScreen.navigateTo(context, group.id.toString());
          break;
      }
    }
  }

  void _deleteGroupChat(BuildContext context, int groupId) async {
    final response = await GroupChatService().deleteGroupChat(groupId);
    if (response) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group chat deleted successfully')),
      );
      setState(() {
        groupChats = GroupChatService().fetchGroupChats();
        // unreadMessages = GroupChatService().fetchUnreadMessages();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete group chat')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Groupes")),
      bottomNavigationBar: const Navbar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Token: ${sharedPrefs.token}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    sharedPrefs.token = "";
                    LoginScreen.navigateTo(context);
                  },
                  child: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Background color
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    DebugPrefsScreen.navigateTo(context);
                  },
                  child: const Text('Debug Shared Preferences'),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              CreateGroupChatScreen.navigateTo(context);
            },
            child: const Text('Créer un nouveau groupe'),
          ),
          Expanded(
            child: FutureBuilder<List<GroupChat>>(
              future: groupChats,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Erreur: ${snapshot.error}"));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    GroupChat group = snapshot.data![index];
                    // int unreadCount = unreadMessagesMap[group.id.toString()] ?? 0;
                    return LongPressListItem(
                      group: group,
                      unreadCount: 0, // ou 0 pour le moment
                      onTap: () {
                        GroupChatScreen.navigateTo(
                            context, group.id.toString(), group.name);
                      },
                      onLongPress: (LongPressStartDetails details) async {
                        _showPopupMenu(context, group);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
