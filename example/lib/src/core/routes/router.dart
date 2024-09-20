import 'package:example/src/pages/avatar_selection_page.dart';
import 'package:example/src/pages/conversation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:example/src/pages/splash_screen.dart';

class AppRouter {
  // GoRouter configuration

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;
  static GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    routes: <RouteBase>[
      GoRoute(
        path: '/select-avatar',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomTransitionPage(
          key: state.pageKey,
          child: AvatarSelectionPage(
            showFollow: state.extra as bool? ?? false,
          ),
          transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) =>
              FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
            child: child,
          ),
        ),
      ),
      GoRoute(
        path: '/conversations',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            CustomTransitionPage(
          key: state.pageKey,
          child: Conversations(
            avatarName: state.extra as String? ?? "Jenna",
          ),
          transitionsBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                  Widget child) =>
              FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOutCirc).animate(animation),
            child: child,
          ),
        ),
      ),

      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      // GoRoute(
      //   path: '/homepage',
      //   builder: (BuildContext context, GoRouterState state) =>
      //       const Homepage(),
      // ),
    ],
  );

  static void goToHomePage() {
    router.go('/homepage');
  }

  static void goToAvatarSelection({bool showFollow = false}) {
    router.go('/select-avatar', extra: showFollow);
  }

  static void goToAbout() {
    router.go('/about-us');
  }

  static void goToFaqs() {
    router.go('/faqs');
  }

  static Future<T?> goToConversation<T extends Object?>(String name) {
    return router.pushReplacement('/conversations', extra: name);
  }
}
