import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/notification.dart';
import 'package:flutter_mobile/services/notification_service.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile/widgets/navbar.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  static String routeName = '/notifications';

  static Future<void> navigateTo(BuildContext context) {
    return context.push(routeName);
  }

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<Notif>> notifications;

  @override
  void initState() {
    super.initState();
    final userId = sharedPrefs.userId;
    notifications = NotificationService().fetchNotificationUser(int.parse(userId));
  }

  @override
  Widget build(BuildContext context) {
    /*
    final List<Notification> notifications = [

      Notification(
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
*/
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: FutureBuilder<List<Notif>>(
        future: notifications,
        builder: (BuildContext context, AsyncSnapshot<List<Notif>>snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                // int unreadCount = unreadMessagesMap[group.id.toString()] ?? 0;
                Notif notification = snapshot.data![index];
                final formattedTime = DateFormat('HH:mm').format(notification.datetime);

                return  ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(notification.icon),
                  ),
                  title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${notification.content}"),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formattedTime, style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("${notification.groupName}", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                );
              },
            );
          }
          return const CircularProgressIndicator();
        },
      ),
      bottomNavigationBar: const Navbar(),
    );
  }
}
