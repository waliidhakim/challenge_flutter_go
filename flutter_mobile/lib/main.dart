import 'package:flutter/material.dart';
import 'package:flutter_mobile/app.dart';
import 'package:flutter_mobile/utils/shared_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  await sharedPrefs.init();
  runApp(const App());
}
