import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugPrefsScreen extends StatefulWidget {
  static String routeName = '/debugPrefs';
  static void navigateTo(BuildContext context) {
    GoRouter.of(context).push(routeName);
  }

  @override
  _DebugPrefsScreenState createState() => _DebugPrefsScreenState();
}

class _DebugPrefsScreenState extends State<DebugPrefsScreen> {
  late SharedPreferences _prefs;
  Map<String, Object> _prefsMap = {};

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _prefsMap = _prefs.getKeys().fold(<String, Object>{},
          (Map<String, Object> map, String key) {
        map[key] = _prefs.get(key)!;
        return map;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug Shared Preferences'),
      ),
      body: ListView(
        children: _prefsMap.entries.map((entry) {
          return ListTile(
            title: Text('${entry.key}'),
            subtitle: Text('${entry.value}'),
          );
        }).toList(),
      ),
    );
  }
}
