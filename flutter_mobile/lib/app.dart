import 'package:flutter/material.dart';
import 'package:flutter_mobile/home/home_screen.dart';
import 'package:flutter_mobile/login/login_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LoginScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
      theme: ThemeData(
        brightness: Brightness.dark
      ),
    );
  }
}

