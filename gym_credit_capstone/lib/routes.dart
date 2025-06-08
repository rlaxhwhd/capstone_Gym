import 'package:flutter/material.dart';

import 'views/screens/login/login_screen.dart';
import 'views/screens/sign_up//sign_up_screen.dart';
import 'views/screens/find_password/find_password.dart';

import 'views/screens/main_screen.dart';

import 'views/screens/home/home_page.dart';
import 'views/screens/meetup/meetup_page.dart';
import 'views/screens/profile/profile_page.dart';
import 'views/screens/profile/delete_account_screen.dart';

import 'views/screens/qrcode/qrcode_page.dart';
import 'views/screens/schedule/schedule_page.dart';

import 'views/screens/profile/nickname_change.dart';
import 'views/screens/profile/phone_change.dart';
import 'views/screens/profile/change_password.dart';
import 'views/screens/profile/new_password.dart';
import 'views/screens/gym_detail/gym_detail_page.dart';

// ✅ 새로 추가
import 'package:gym_credit_capstone/views/screens/unsorted/selected_sports_list.dart';
import 'package:gym_credit_capstone/views/screens/profile/usage_history_screen.dart'; // ✅ 새로 추가

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
  static const String changeNickname = '/change_nickname';
  static const String changePhone = '/change_phone';
  static const String changePassword = '/change_password';
  static const String newPassword = '/new_password';
  static const String usageHistory = '/usage_history'; // ✅ 이용내역 추가

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case findPassword:
        return MaterialPageRoute(builder: (_) => const FindPassword());
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
      case newPassword:
        return MaterialPageRoute(builder: (_) => const NewPasswordScreen());
      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case changePhone:
        return MaterialPageRoute(builder: (_) => const PhoneChangeScreen());
      case changeNickname:
        return MaterialPageRoute(builder: (_) => const NicknameChangeScreen());
      case logOut:
        return MaterialPageRoute(builder: (_) => const DeleteAccountScreen());
      case selectedSportsList:
        final args = settings.arguments as List<String>;
        return MaterialPageRoute(
          builder: (_) => SelectedSportsList(selectedSports: args),
        );
      case usageHistory:
        return MaterialPageRoute(builder: (_) => const UsageHistoryScreen()); // ✅ 추가
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('404 Not Found'))),
        );
    }
  }
}
