import 'package:flutter/material.dart';

import 'views/screens/login/login_screen.dart';
import 'views/screens/login/sign_up_screen.dart';
import 'views/screens/login/find_password_screen.dart';

import 'views/screens/main_screen.dart';

import 'views/screens/home/home_page.dart';
import 'views/screens/meetup/meetup_page.dart';
import 'views/screens/profile/profile_page.dart';
import 'views/screens/profile/delete_account_screen.dart';

import 'views/screens/qrcode/qrcode_page.dart';
import 'views/screens/schedule/schedule_page.dart';

import 'views/screens/unsorted/gym_info_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String findPassword = '/find_pw';
  static const String logOut = '/deleteAccount';

  static const String home = '/home';
  static const String main = '/main';
  static const String meetup = '/meetup';
  static const String profile = '/profile';
  static const String qrcode = '/qrcode';
  static const String schedule = '/schedule';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case findPassword:
        return MaterialPageRoute(builder: (_) => const FindPasswordScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case meetup:
        return MaterialPageRoute(builder: (_) => const MeetupPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case qrcode:
        return MaterialPageRoute(builder: (_) => const QrcodePage());
      case schedule:
        return MaterialPageRoute(builder: (_) => const SchedulePage());
      case logOut:
        return MaterialPageRoute(builder: (_) => const DeleteAccountScreen());
      default:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(body: Center(child: Text('404 Not Found'))));
    }
  }
}
