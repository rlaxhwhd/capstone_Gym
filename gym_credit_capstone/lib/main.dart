import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'routes.dart';
import 'view_models/liked_gym_view_model.dart';
import 'view_models/delete_account_viewmodel.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/gym_Info_repository.dart';
import 'package:gym_credit_capstone/view_models/filtered_gym_view_model.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final authRepository = AuthRepository();
  final userRepository = UserRepository(authRepository: authRepository);
  final gymInfoRepository = GymInfoRepository();
  await NaverMapSdk.instance.initialize(clientId: '19yms2ttr3',);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LikedGymViewModel(
          userRepository: userRepository,
          gymInfoRepository: gymInfoRepository,
        )), // LikedGymViewModel 등록
        ChangeNotifierProvider(create: (context) => DeleteAccountViewModel()), // DeleteAccountViewModel 등록
        ChangeNotifierProvider(create: (context) => FilteredGymViewModel(
          gymInfoRepository: gymInfoRepository, // 여기서 gymInfoRepository 전달
        )), // FilteredGymViewModel 등록
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
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
      theme: ThemeData(
        fontFamily: 'nanumgothic',
      ),
    );
  }
}
