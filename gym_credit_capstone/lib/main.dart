import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/*import 'package:gym_credit_capstone/views/screens/login/login_screen.dart';
import 'package:gym_credit_capstone/views/screens/login/sign_up_screen.dart';
//import 'package:gym_credit_capstone/view/screens/success_screen.dart';
import 'package:gym_credit_capstone/views/screens/login/find_password_screen.dart';
import 'package:gym_credit_capstone/views/screens/login/login_success.dart';

import 'package:gym_credit_capstone/views/screens/main_screen.dart';
import 'package:gym_credit_capstone/view_models/home_events_view_model.dart';*/

import 'routes.dart';
import 'view_models/liked_gym_view_model.dart';
import 'view_models/delete_account_viewmodel.dart';
import 'view_models/filtered_gym_view_model.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/gym_Info_repository.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final authRepository = AuthRepository();
  final userRepository = UserRepository(authRepository: authRepository);
  final gym_Info_repository = GymInfoRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LikedGymViewModel(
            userRepository: userRepository,
            gymInfoRepository: gym_Info_repository,
          ),
        ), // LikedGymViewModel 등록
        ChangeNotifierProvider(create: (context) => DeleteAccountViewModel()), // DeleteAccountViewModel 등록
        ChangeNotifierProvider(
          create: (context) => FilteredGymViewModel(gymInfoRepository: gym_Info_repository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      /*initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(), // SignUpScreen 사용
        '/find_pw': (context) => FindPasswordScreen(),
        '/success': (context) => SuccessScreen(),
        '/main': (context) => MainScreen(),
      },*/
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
