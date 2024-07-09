import 'package:flutter/material.dart';

enum NotificationLevel { all, partial, none }

class NotificationSelection extends StatefulWidget {
  const NotificationSelection({super.key});

  @override
  State<NotificationSelection> createState() => _NotificationSelectionState();
}

class _NotificationSelectionState extends State<NotificationSelection> {
  NotificationLevel? _notificationLevel = NotificationLevel.all;
  double _currentSliderValue = 5;

  void handleNotificationLevelChange(NotificationLevel? value) {
    setState(() {
      _notificationLevel = value;
    });
  }
  void handleGroupActivityThresholdChange(double value) {
    setState(() {
      _currentSliderValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Notifications push",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              "Choisissez les occurrences de notifications. Elles ont un impact global et définissent le comportement par défaut dans les groupes.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            ListTile(
              title: const Text('Toutes'),
              subtitle: const Text("Groupes, Messages, Activités, ..."),
              leading: Radio<NotificationLevel>(
                value: NotificationLevel.all,
                groupValue: _notificationLevel,
                onChanged: (value) => handleNotificationLevelChange(value),
              ),
            ),
            ListTile(
              title: const Text('Partielles'),
              subtitle: const Text("Seulement les mentions et rappels."),
              leading: Radio<NotificationLevel>(
                value: NotificationLevel.partial,
                groupValue: _notificationLevel,
                onChanged: (value) => handleNotificationLevelChange(value),
              ),
            ),
            ListTile(
              title: const Text('Désactivées'),
              subtitle: const Text("Seulement les mentions et rappels."),
              leading: Radio<NotificationLevel>(
                value: NotificationLevel.none,
                groupValue: _notificationLevel,
                onChanged: (value) => handleNotificationLevelChange(value),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Notifications d'activité de groupe",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text(
              "Choisissez à partir de combien de participant vous souhaitez être notifié d'une activité de groupe.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Slider(
              value: _currentSliderValue,
              max: 20,
              min: 1,
              divisions: 5,
              label: _currentSliderValue.round().toString(),
              onChanged: (double value) => handleGroupActivityThresholdChange(value),
            )
          ],
        )
      ],
    );
  }
}
