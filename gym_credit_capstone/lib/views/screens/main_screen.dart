import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/main_view_model.dart';
import 'home/home_page.dart';
import 'schedule/schedule_page.dart';
import 'profile/profile_page.dart';
import 'meetup/meetup_page.dart';
import 'qrcode/qrcode_page.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => MainViewModel(),
      child: Consumer<MainViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: IndexedStack(
              index: viewModel.currentIndex, // 현재 선택된 탭 인덱스
              children: const [
                HomePage(),
                SchedulePage(),
                QrcodePage(),
                MeetupPage(),
                ProfilePage(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: viewModel.currentIndex,
              onTap: (index) {
                viewModel.changeTab(index); // 탭 변경 시 상태 업데이트
              },
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
                BottomNavigationBarItem(icon: Icon(Icons.schedule), label: "시간표"),
                BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "바코드"),
                BottomNavigationBarItem(icon: Icon(Icons.group), label: "모임"),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: "내 정보"),
              ],
              selectedItemColor: const Color(0xff69b6ff),
              unselectedItemColor: const Color(0xffb1b3b5),
            ),
          );
        },
      ),
    );
  }
}
