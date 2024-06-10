import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Statistiques',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true, // Centrer le titre dans la AppBar
        backgroundColor:
            Colors.lightBlue[100], // Uniformité avec les autres pages
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'Graphiques et statistiques ici',
          style: TextStyle(
              fontSize: 16), // Optionnel pour augmenter la taille du texte
        ),
      ),
    );
  }
}
