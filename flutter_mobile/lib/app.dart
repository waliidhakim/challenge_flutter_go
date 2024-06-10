import 'package:flutter/material.dart';
import 'package:flutter_mobile/screens/home/home_screen.dart';
import 'package:flutter_mobile/screens/login/login_screen.dart';
import 'package:flutter_mobile/screens/onboard/onboard_screen.dart';

RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      routes: {
        '/': (context) => const HomeScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        OnboardScreen.routeName: (context) => const OnboardScreen(),
      },
      theme: ThemeData(
        brightness: Brightness.light
      ),
    );
  }
}

