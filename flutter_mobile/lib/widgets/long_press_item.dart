import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/group_chat.dart';

class LongPressListItem extends StatelessWidget {
  final GroupChat group;
  final int unreadCount;
  final VoidCallback onTap;
  final void Function(LongPressStartDetails) onLongPress;

  const LongPressListItem({
    required this.group,
    required this.unreadCount,
    required this.onTap,
    required this.onLongPress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPressStart: onLongPress,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: group.imageUrl.isNotEmpty
              ? NetworkImage(group.imageUrl)
              : AssetImage('assets/images/default_group.png') as ImageProvider,
        ),
        title: Text(group.name),
        subtitle: Text(group.catchPhrase),
        trailing: unreadCount > 0
            ? CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            : null,
      ),
    );
  }
}
