import 'package:flutter/material.dart';
import 'package:flutter_mobile/models/settings.dart';
import 'package:flutter_mobile/services/settings_service.dart';

class NotificationSelection extends StatefulWidget {
  final Function(Setting settings)? onChange;

  const NotificationSelection({super.key, required this.onChange});

  @override
  State<NotificationSelection> createState() => _NotificationSelectionState();
}

class _NotificationSelectionState extends State<NotificationSelection> {
  NotificationLevel _notificationLevel = NotificationLevel.all;
  double _currentSliderValue = 5;
  late Future<Setting> settings;

  void handleNotificationLevelChange(NotificationLevel value) {
    setState(() {
      _notificationLevel = value;
    });
    pushChanges();
  }

  void handleGroupActivityThresholdChange(double value) {
    setState(() {
      _currentSliderValue = value;
    });
    pushChanges();
  }

  void pushChanges() {
    widget.onChange!(Setting(
      notifyLevel: _notificationLevel,
      notifyThreshold: _currentSliderValue.round(),
    ));
  }

  @override
  void initState() {
    super.initState();
    settings = SettingsService().fetchUserSettings();
    // set state with the fetched settings
    settings.then((value) {
      _notificationLevel = value.notifyLevel;
      _currentSliderValue = value.notifyThreshold.toDouble();
    });
  }

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FutureBuilder(
            future: settings,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notifications push",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
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
                        onChanged: (value) => {
                          if (value != null) {handleNotificationLevelChange(value)}
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Partielles'),
                      subtitle: const Text("Seulement les mentions et rappels."),
                      leading: Radio<NotificationLevel>(
                        value: NotificationLevel.partial,
                        groupValue: _notificationLevel,
                        onChanged: (value) => {
                          if (value != null) {handleNotificationLevelChange(value)}
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Désactivées'),
                      subtitle: const Text("Seulement les mentions et rappels."),
                      leading: Radio<NotificationLevel>(
                        value: NotificationLevel.none,
                        groupValue: _notificationLevel,
                        onChanged: (value) => {
                          if (value != null) {handleNotificationLevelChange(value)}
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Notifications d'activité de groupe",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
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
                      onChanged: (double value) =>
                          handleGroupActivityThresholdChange(value),
                    )
                  ],
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return const CircularProgressIndicator();
            }),
      ],
    );
  }
}
