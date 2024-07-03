import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/group_chat.dart';

class LongPressListItem extends StatelessWidget {
  final GroupChat group;
  final VoidCallback onTap;
  final Function(LongPressStartDetails) onLongPress;

  LongPressListItem({
    required this.group,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: onLongPress,
      child: ListTile(
        leading: GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            backgroundImage: NetworkImage(group.imageUrl),
          ),
        ),
        title: Text(group.name),
        subtitle: Text("${group.catchPhrase} - ${group.lastMessage}"),
        trailing: group.unreadCount > 0
            ? CircleAvatar(
                backgroundColor: Colors.red,
                radius: 12,
                child: Text('${group.unreadCount}',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              )
            : null,
      ),
    );
  }
}
