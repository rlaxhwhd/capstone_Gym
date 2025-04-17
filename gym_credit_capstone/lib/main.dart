import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import 'routes.dart';
import 'view_models/liked_gym_view_model.dart';
import 'view_models/delete_account_viewmodel.dart';
import 'view_models/selected_sports_list_view_model.dart';
import 'view_models/meetup_view_model.dart';
import 'view_models/gym_booking_view_model.dart'; // GymBookingViewModel 추가

import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/gym_info_repository.dart';
import 'data/repositories/meetup_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final authRepository = AuthRepository();
  final userRepository = UserRepository(authRepository: authRepository);
  final gymInfoRepository = GymInfoRepository();
  final meetupRepository = MeetupRepository();

  await NaverMapSdk.instance.initialize(clientId: '19yms2ttr3'); // 네이버 맵 SDK 초기화

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LikedGymViewModel(
            userRepository: userRepository,
            gymInfoRepository: GymInfoRepository(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => DeleteAccountViewModel()),
        ChangeNotifierProvider(
          create: (_) => SelectedSportsListViewModel(gymInfoRepository: gymInfoRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => MeetupViewModel(meetupRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => GymBookingViewModel(), // GymBookingViewModel 추가
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GymBookingViewModel()), // 추가 등록
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRoutes.generateRoute,
        theme: ThemeData(
          fontFamily: 'nanumgothic',
        ),
      ),
    );
  }
}