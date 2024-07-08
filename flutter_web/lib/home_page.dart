import 'package:flutter/material.dart';
import 'package:flutter_web/stats_page.dart';
import 'package:flutter_web/login_page.dart';
import 'package:flutter_web/user_crud_page.dart';
import 'package:flutter_web/group_chat_crud_page.dart'; // Importer la nouvelle page

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Accueil',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold), // Couleur blanche et texte en gras
        ),
        centerTitle: true, // Centre le titre
        backgroundColor:
            Colors.lightBlue[100], // Couleur de fond de la barre de navigation
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10), // Bordure arrondie pour l'appBar
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 119, 203,
                    241), // Harmonisation des couleurs avec le bouton de connexion
              ),
              child: Text('Menu Admin',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.lightBlue),
              title: const Text('Utilisateurs'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserCrudPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.lightBlue),
              title: const Text('Statistiques'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const StatsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.lightBlue),
              title: const Text('Group Chats'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const GroupChatCrudPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.lightBlue),
              title: const Text('Déconnexion'),
              onTap: () {
                // Gérer la déconnexion ici
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Bienvenue sur la page d\'accueil',
          style: TextStyle(fontSize: 20), // Style ajouté pour agrandir le texte
        ),
      ),
    );
  }
}
