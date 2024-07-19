import 'package:flutter/material.dart';
import 'package:flutter_web/services/features/feature_service.dart';

class CreateFeatureDialog {
  static void show(BuildContext context, Function onFeatureCreated) {
    final _featureNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Create New Feature'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _featureNameController,
                  decoration: const InputDecoration(labelText: 'Feature Name'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () async {
                bool success = await FeatureService.createFeature(
                    _featureNameController.text);
                if (success) {
                  Navigator.of(dialogContext).pop();
                  onFeatureCreated();
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                          content: Text('Failed to create feature'),
                          backgroundColor: Colors.red));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
