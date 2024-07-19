import 'package:flutter/material.dart';
import 'package:flutter_mobile/app.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';

class AppSettings {
  String apiUrl = 'http://52.47.172.229:4000';
  String wsUrl = 'ws://52.47.172.229:4000';
//String apiUrl = 'http://10.0.2.2:4000';
//String wsUrl = 'ws://10.0.2.2:4000';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sharedPrefs.init();
  runApp(const App());
}
