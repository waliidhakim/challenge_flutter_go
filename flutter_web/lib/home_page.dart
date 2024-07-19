import 'package:flutter/material.dart';
import 'package:flutter_web/log_page.dart';
import 'package:flutter_web/stats_page.dart';
import 'package:flutter_web/login_page.dart';
import 'package:flutter_web/user_crud_page.dart';
import 'package:flutter_web/group_chat_crud_page.dart';
import 'package:flutter_web/feature_management_page.dart';
import 'package:flutter_web/user_stats_page.dart'; // Importez la nouvelle page

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Accueil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[100],
        elevation: 4.0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 119, 203, 241),
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
            ExpansionTile(
              leading: const Icon(Icons.bar_chart, color: Colors.lightBlue),
              title: const Text('Statistiques'),
              children: [
                ListTile(
                  leading: const Icon(Icons.chat, color: Colors.lightGreen),
                  title: const Text('Group Chats'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StatsPage()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.lightGreen),
                  title: const Text('Utilisateurs'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserStatsPage()));
                  },
                ),
              ],
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
              leading: const Icon(Icons.settings, color: Colors.lightBlue),
              title: const Text('Gestion de Fonctionnalités'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FeatureManagementPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.article, color: Colors.lightBlue),
              title: const Text('Logs'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LogPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.lightBlue),
              title: const Text('Déconnexion'),
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenue sur la page d\'accueil',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.admin_panel_settings,
                    size: 250, color: Colors.lightBlue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
