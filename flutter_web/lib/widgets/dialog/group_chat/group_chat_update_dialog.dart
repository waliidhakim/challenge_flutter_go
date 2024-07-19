import 'package:flutter/material.dart';
import 'package:flutter_web/services/group_chat/group_chat_service.dart';

class UpdateGroupChatDialog extends StatefulWidget {
  final Map<String, dynamic> groupChatData;
  final VoidCallback onUpdateSuccess;

  const UpdateGroupChatDialog({
    Key? key,
    required this.groupChatData,
    required this.onUpdateSuccess,
  }) : super(key: key);

  static void show(BuildContext context, Map<String, dynamic> groupChatData,
      VoidCallback onUpdateSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UpdateGroupChatDialog(
          groupChatData: groupChatData,
          onUpdateSuccess: onUpdateSuccess,
        );
      },
    );
  }

  @override
  _UpdateGroupChatDialogState createState() => _UpdateGroupChatDialogState();
}

class _UpdateGroupChatDialogState extends State<UpdateGroupChatDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _activity;
  late String _catchPhrase;
  late List<String> _newMembers;

  @override
  void initState() {
    super.initState();
    _name = widget.groupChatData['Name'];
    _activity = widget.groupChatData['Activity'];
    _catchPhrase = widget.groupChatData['CatchPhrase'];
    _newMembers = [];
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await GroupChatService.updateGroupChat(widget.groupChatData['ID'], {
          'name': _name,
          'activity': _activity,
          'catchPhrase': _catchPhrase,
          'new_members': _newMembers,
        });
        widget.onUpdateSuccess();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('GroupChat updated successfully'),
              backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update group chat: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update GroupChat: ${widget.groupChatData['Name']}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: ListBody(
            children: <Widget>[
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name'),
                onSaved: (value) => _name = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                initialValue: _activity,
                decoration: InputDecoration(labelText: 'Activity'),
                onSaved: (value) => _activity = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an activity' : null,
              ),
              TextFormField(
                initialValue: _catchPhrase,
                decoration: InputDecoration(labelText: 'Catch Phrase'),
                onSaved: (value) => _catchPhrase = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a catch phrase' : null,
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'New Members (comma separated phones)'),
                onSaved: (value) => _newMembers =
                    value!.split(',').map((e) => e.trim()).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Update'),
          onPressed: _submit,
        ),
      ],
    );
  }
}
