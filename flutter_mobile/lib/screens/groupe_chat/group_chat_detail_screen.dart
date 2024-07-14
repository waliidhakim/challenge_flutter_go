import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/group_chat.dart';
import 'package:flutter_mobile/models/user_model.dart';
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
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                groupChat.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text("Activité: ${groupChat.activity}"),
              const SizedBox(height: 8),
              Text("Phrase d'accroche: ${groupChat.catchPhrase}"),
              const SizedBox(height: 16),
              Center(
                child: CircleAvatar(
                  radius: 150,
                  backgroundImage: NetworkImage(groupChat.imageUrl),
                  onBackgroundImageError: (_, __) {
                    // Handle error if needed
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Center(
              //   child: Image.network(
              //     groupChat.imageUrl,
              //     width: 100,
              //     height: 100,
              //     fit: BoxFit.cover,
              //   ),
              // ),
              // const SizedBox(height: 16),
              Text(
                "Membres du groupe:",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              ...groupChat.users.map((groupChatUser) {
                User user = groupChatUser.user;
                return ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(user.avatarUrl),
                    onBackgroundImageError: (_, __) {
                      // Handle error if needed
                    },
                    child: user.avatarUrl.isEmpty ? Icon(Icons.person) : null,
                  ),
                  title: Text(user.username),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${user.firstname} ${user.lastname}'),
                      Text(user.phone),
                    ],
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
