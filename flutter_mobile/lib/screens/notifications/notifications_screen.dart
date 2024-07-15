import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile/widgets/navbar.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static String routeName = '/notifications';

  static Future<void> navigateTo(BuildContext context) {
    return context.push(routeName);
  }

  @override
  Widget build(BuildContext context) {
    final List<NotificationItem> notifications = [
      NotificationItem(
        title: "Message from John",
        description: "Description de la notification 1",
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        groupName: "Group 1",
        senderName: "John",
        groupImageUrl: "https://via.placeholder.com/150", // Replace with actual image URLs
      ),
      NotificationItem(
        title: "Message from Alice",
        description: "Description de la notification 2",
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        groupName: "Group 2",
        senderName: "Alice",
        groupImageUrl: "https://via.placeholder.com/150", // Replace with actual image URLs
      ),
      NotificationItem(
        title: "Message from Bob",
        description: "Description de la notification 3",
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        groupName: "Group 3",
        senderName: "Bob",
        groupImageUrl: "https://via.placeholder.com/150", // Replace with actual image URLs
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final formattedTime = DateFormat('HH:mm').format(notification.timestamp);
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.grey, width: 1),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: InkWell(
              onTap: () {
                // Handle notification tap
              },
              child: ListTile(
                contentPadding: const EdgeInsets.all(8),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(notification.groupImageUrl),
                ),
                title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("From: ${notification.senderName}"),
                    Text(notification.description),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formattedTime, style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text("Group: ${notification.groupName}", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const Navbar(),
    );
  }
}

class NotificationItem {
  final String title;
  final String description;
  final DateTime timestamp;
  final String groupName;
  final String senderName;
  final String groupImageUrl;

  NotificationItem({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.groupName,
    required this.senderName,
    required this.groupImageUrl,
  });
}
