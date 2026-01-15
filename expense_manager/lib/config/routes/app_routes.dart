import 'package:expense_manager/presentation/auth/login_screen.dart';
import 'package:expense_manager/presentation/auth/register_screen.dart';
import 'package:expense_manager/presentation/navigation/main_navigation.dart';
import 'package:flutter/material.dart';


class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  
  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const MainNavigation(),
    };
  }
}