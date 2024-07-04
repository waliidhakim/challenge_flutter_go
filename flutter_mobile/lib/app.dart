// import 'package:flutter/material.dart';
// import 'package:flutter_mobile/screens/home/home_screen.dart';
// import 'package:flutter_mobile/screens/login/login_screen.dart';
// import 'package:flutter_mobile/screens/onboard/onboard_screen.dart';

// RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// class App extends StatelessWidget {
//   const App({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       navigatorObservers: [routeObserver],
//       routes: {
//         '/': (context) => const HomeScreen(),
//         LoginScreen.routeName: (context) => const LoginScreen(),
//         HomeScreen.routeName: (context) => const HomeScreen(),
//         OnboardScreen.routeName: (context) => const OnboardScreen(),
//       },
//       theme: ThemeData(
//         brightness: Brightness.light
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_mobile/screens/calendar/calendar_screen.dart';
import 'package:flutter_mobile/screens/groupe_chat/create_group_chat_screen.dart';
import 'package:flutter_mobile/screens/groupe_chat/group_chat_detail_screen.dart';
import 'package:flutter_mobile/screens/groupe_chat/group_chat_screen.dart';
import 'package:flutter_mobile/screens/notifications/notifications_screen.dart';
import 'package:flutter_mobile/screens/settings/settings_screen.dart';
import 'package:flutter_mobile/utils/screen_arguments.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_mobile/screens/home/home_screen.dart';
import 'package:flutter_mobile/screens/login/login_screen.dart';
import 'package:flutter_mobile/screens/onboard/onboard_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (BuildContext context, GoRouterState state) =>
              const LoginScreen(),
        ),
        GoRoute(
          path: HomeScreen.routeName,
          pageBuilder: (BuildContext context, GoRouterState state) =>
          const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: NotificationScreen.routeName,
          pageBuilder: (BuildContext context, GoRouterState state) =>
              const NoTransitionPage(child: NotificationScreen()),
        ),
        GoRoute(
          path: CalendarScreen.routeName,
          pageBuilder: (BuildContext context, GoRouterState state) =>
              NoTransitionPage(
            key: state.pageKey,
            child: const CalendarScreen(),
          ),
        ),
        GoRoute(
          path: SettingsScreen.routeName,
          pageBuilder: (BuildContext context, GoRouterState state) =>
              NoTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
          ),
        ),
        GoRoute(
          path: '/onboard',
          builder: (BuildContext context, GoRouterState state) {
            final args = state.extra as ScreenArguments;
            return OnboardScreen(arguments: args);
          },
        ),
        GoRoute(
          path: '/createGroupChat',
          builder: (BuildContext context, GoRouterState state) =>
              const CreateGroupChatScreen(), // Ajoutez cette ligne
        ),
        GoRoute(
          path: '/groupChatDetail',
          builder: (BuildContext context, GoRouterState state) {
            final groupId = state.extra as String;
            return GroupChatDetailScreen(groupId: groupId);
          },
        ),
        GoRoute(
          path: '/groupChat',
          builder: (BuildContext context, GoRouterState state) {
            final groupId = state.extra as String;
            return GroupChatScreen(groupId: groupId);
          },
        ),
      ],
      errorPageBuilder: (context, state) => MaterialPage(
        child: Scaffold(
          body: Center(
            child: Text(state.error.toString()),
          ),
        ),
      ),
    );

    return MaterialApp.router(
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
    );
  }
}
