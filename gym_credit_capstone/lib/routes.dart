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

import 'views/screens/gym_detail/gym_detail_page.dart';

// ✅ 새로 추가
import 'package:gym_credit_capstone/views/screens/unsorted/selected_sports_list.dart';

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

  // ✅ 새 route 추가
  static const String selectedSportsList = '/selected_sports_list';

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
        final userId = settings.arguments as String?; // arguments로 userId 가져오기
        if (userId != null) {
          return MaterialPageRoute(builder: (_) => SchedulePage());
        } else {
          return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('User ID 없음'))));
        }
      case logOut:
        return MaterialPageRoute(builder: (_) => const DeleteAccountScreen());
      case selectedSportsList:
        final args = settings.arguments as List<String>;
        return MaterialPageRoute(
          builder: (_) => SelectedSportsList(selectedSports: args),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('404 Not Found'))),
        );
    }
  }
}
