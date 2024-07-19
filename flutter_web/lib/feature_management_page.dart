import 'package:flutter/material.dart';
import 'package:flutter_web/services/features/feature_service.dart'; // Assurez-vous que le chemin est correct
import 'package:flutter_web/widgets/dialog/feature/create_feature_dialog.dart';

class FeatureManagementPage extends StatefulWidget {
  const FeatureManagementPage({super.key});

  @override
  _FeatureManagementPageState createState() => _FeatureManagementPageState();
}

class _FeatureManagementPageState extends State<FeatureManagementPage> {
  late Future<List<dynamic>> features;

  @override
  void initState() {
    super.initState();
    features = FeatureService.fetchFeatures();
  }

  void _confirmToggleFeature(dynamic feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text(
              'Vous êtes sur le point d${feature['IsActive'] ? "e désactiver" : "'activer"} une fonctionnalité. Êtes-vous sûr de vouloir continuer ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _toggleFeature(feature);
              },
              child: const Text('Continuer'),
            ),
          ],
        );
      },
    );
  }

  void _toggleFeature(dynamic feature) {
    bool newValue = !feature['IsActive'];
    FeatureService.updateFeature(feature['ID'], newValue).then((_) {
      setState(() {
        feature['IsActive'] = newValue;
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update feature: $error')));
    });
  }

  void _confirmDeleteFeature(dynamic feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation de suppression'),
          content: Text(
              'Êtes-vous sûr de vouloir supprimer cette fonctionnalité : "${feature['FeatureName']}" ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteFeature(feature);
              },
              child:
                  const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteFeature(dynamic feature) {
    FeatureService.deleteFeature(feature['ID']).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Feature deleted successfully'),
            backgroundColor: Colors.green));
        setState(() {
          features = FeatureService.fetchFeatures();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to delete feature'),
            backgroundColor: Colors.red));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Gestion des Fonctionalités',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true, // Centrer le titre dans la AppBar
        backgroundColor:
            Colors.lightBlue[100], // Couleur uniforme avec les autres pages
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Create New Feature'),
                onPressed: () => CreateFeatureDialog.show(context, () {
                  setState(() {
                    features = FeatureService.fetchFeatures();
                  });
                }),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: features,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const <DataColumn>[
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Nom de la fonctionnalité')),
                        DataColumn(label: Text('État')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: snapshot.data!
                          .map<DataRow>((feature) => DataRow(
                                cells: <DataCell>[
                                  DataCell(Text('${feature['ID']}')),
                                  DataCell(Text(feature['FeatureName'])),
                                  DataCell(Icon(
                                      feature['IsActive']
                                          ? Icons.check
                                          : Icons.close,
                                      color: feature['IsActive']
                                          ? Colors.green
                                          : Colors.red)),
                                  DataCell(Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _confirmDeleteFeature(feature),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                            feature['IsActive']
                                                ? Icons.power_settings_new
                                                : Icons.power_off,
                                            color: feature['IsActive']
                                                ? Colors.green
                                                : Colors.red),
                                        onPressed: () =>
                                            _confirmToggleFeature(feature),
                                      ),
                                    ],
                                  )),
                                ],
                              ))
                          .toList(),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
