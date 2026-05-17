// Path: routes\app_routes.dart
import 'package:flutter/material.dart';
import '../modules/auth/screens/splash_screen.dart';
import '../modules/auth/screens/login_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  
  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
    };
  }
}