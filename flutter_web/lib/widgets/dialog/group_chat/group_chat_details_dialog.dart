import 'package:flutter/material.dart';

class GroupChatDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> groupChatData;

  const GroupChatDetailsDialog({Key? key, required this.groupChatData})
      : super(key: key);

  static void show(BuildContext context, Map<String, dynamic> groupChatData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GroupChatDetailsDialog(groupChatData: groupChatData);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Details for GroupChat: ${groupChatData['Name']}'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('Activity: ${groupChatData['Activity']}'),
            Text('Catch Phrase: ${groupChatData['CatchPhrase']}'),
            Text('Alert: ${groupChatData['Alert']}'),
            if (groupChatData['ImageUrl'] != null)
              Image.network(groupChatData['ImageUrl']),
            const SizedBox(height: 10),
            Text('Users:', style: TextStyle(fontWeight: FontWeight.bold)),
            for (var user in groupChatData['Users'])
              ListTile(
                leading: user['User']['AvatarUrl'] != null
                    ? Image.network(user['User']['AvatarUrl'],
                        width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.person, size: 50),
                title: Text(
                    '${user['User']['Firstname']} ${user['User']['Lastname']}'),
                subtitle: Text('${user['User']['Username']} - ${user['Role']}'),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
