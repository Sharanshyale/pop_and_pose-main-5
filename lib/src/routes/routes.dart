import 'package:flutter/material.dart';
import 'package:pop_and_pose/src/feature/screen/choose_screen/page/choose_screen.dart';
import 'package:pop_and_pose/src/feature/screen/createUser/page/create_user_page.dart';
import 'package:pop_and_pose/src/feature/screen/splash_screen/page/splash_screen.dart';
import 'package:pop_and_pose/src/feature/screen/testScreen/testScreen.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) => const Testscreen(),
        );

      case '/user-login-screen':
        return MaterialPageRoute(
          builder: (context) => const ChooseScreenPage(userId: "",),
        );

      default:
        return null;
    }
  }
}
