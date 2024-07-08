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
import 'package:flutter_mobile/screens/debug/debud_prefs_screen.dart';
import 'package:flutter_mobile/screens/groupe_chat/add_members_to_group_chat_screen.dart';
import 'package:flutter_mobile/screens/groupe_chat/create_group_chat_screen.dart';
import 'package:flutter_mobile/screens/groupe_chat/edit_group_chat_screen.dart';

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
              const CreateGroupChatScreen(),
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
            final extra = state.extra as Map<String, String>;
            final groupId = extra['groupId']!;
            final groupName = extra['groupName']!;
            return GroupChatScreen(
              groupId: groupId,
              groupName: groupName,
            );
          },
        ),
        GoRoute(
          path: '/add_members',
          builder: (BuildContext context, GoRouterState state) {
            final groupId = state.extra as String;
            print(
                "----------router to add member screen for group $groupId------------");
            return AddMembersScreen(groupChatId: groupId);
          },
        ),
        GoRoute(
          path: EditGroupChatScreen.routeName,
          builder: (BuildContext context, GoRouterState state) {
            final extra = state.extra as Map<String, String>;
            return EditGroupChatScreen(
              groupId: extra['groupId']!,
              groupName: extra['groupName']!,
              groupActivity: extra['groupActivity']!,
              groupCatchPhrase: extra['groupCatchPhrase']!,
              imageUrl: extra['imageUrl']!,
            );
          },
        ),
        // Ajoutez cette route
        GoRoute(
          path: DebugPrefsScreen.routeName,
          builder: (BuildContext context, GoRouterState state) =>
              DebugPrefsScreen(),
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
