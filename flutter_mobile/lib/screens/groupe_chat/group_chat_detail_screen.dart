import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/group_chat.dart';
import 'package:flutter_mobile/services/groupe_chat_service.dart';
import 'package:go_router/go_router.dart';

class GroupChatDetailScreen extends StatelessWidget {
  final String groupId;

  const GroupChatDetailScreen({super.key, required this.groupId});

  static String routeName = '/groupChatDetail';

  static Future<void> navigateTo(BuildContext context, String groupId) {
    return context.push(routeName, extra: groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Détails du groupe")),
      body: FutureBuilder<GroupChat>(
        future: GroupChatService().fetchGroupChatById(groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }
          GroupChat groupChat = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  groupChat.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text("Activité: ${groupChat.activity}"),
                const SizedBox(height: 8),
                Text("Phrase d'accroche: ${groupChat.catchPhrase}"),
                const SizedBox(height: 8),
                Image.network(groupChat.imageUrl),
                // const SizedBox(height: 8),
                // Text("Créé par: ${groupChat.owner.username}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
