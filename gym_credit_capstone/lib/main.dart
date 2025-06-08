import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'routes.dart';
import 'view_models/liked_gym_view_model.dart';
import 'view_models/delete_account_viewmodel.dart';
import 'view_models/selected_sports_list_view_model.dart';
import 'view_models/gym_booking_view_model.dart'; // GymBookingViewModel 추가
import 'view_models/schedule_view_model.dart'; // GymBookingViewModel 추가
import 'view_models/main_view_model.dart'; // GymBookingViewModel 추가

import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/gym_info_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");

  final authRepository = AuthRepository();
  final userRepository = UserRepository(authRepository: authRepository);
  final gymInfoRepository = GymInfoRepository();

  await NaverMapSdk.instance.initialize(
    clientId: dotenv.env['NAVER_MAP_CLIENT_ID']!,
  );

  // 상단바 투명 처리
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 전체화면 설정
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LikedGymViewModel(
            userRepository: userRepository,
            gymInfoRepository: gymInfoRepository,
          ),
        ),
        ChangeNotifierProvider(create: (_) => DeleteAccountViewModel()),
        ChangeNotifierProvider(
          create: (_) => SelectedSportsListViewModel(gymInfoRepository: gymInfoRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => GymBookingViewModel(), // GymBookingViewModel 추가
        ),
        ChangeNotifierProvider(create: (_) => MainViewModel()),
        ChangeNotifierProvider(create: (_) => ScheduleViewModel()),
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
        fontFamily: 'NanumSquare', // 폰트 지정
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // 영어
        const Locale('ko', 'KR'), // 한국어
      ],
    );
  }
}