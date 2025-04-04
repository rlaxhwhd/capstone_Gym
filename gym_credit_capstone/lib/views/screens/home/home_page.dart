import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/data/repositories/gym_Info_repository.dart';
import 'package:gym_credit_capstone/data/repositories/user_repository.dart';
import 'package:provider/provider.dart';
import '../../../view_models/background_view_model.dart';
import 'components/background_img.dart';
import '../../../view_models/liked_gym_view_model.dart';
import 'components/home_events_card.dart';
import 'components/sports_select_form.dart';
//import 'components/background_img.dart';
import 'components/sliderWithIndicator.dart';
import '../unsorted/gym_info_page.dart';
//import 'package:gym_credit_capstone/views/screens/unsorted/gym_info_page.dart'; // gym_info_page 추가
//import 'package:gym_credit_capstone/view_models/home_events_view_model.dart'; // 경로 수정 (M → m)

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BackgroundViewModel()), // 닉네임 로드용 ViewModel
        ChangeNotifierProvider(create: (_) => LikedGymViewModel(
          userRepository: UserRepository(),
          gymInfoRepository: GymInfoRepository(),
        )..fetchLikedGyms()), // 이벤트 로드용 ViewModel
      ],
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0,
        ),
        body: Consumer<LikedGymViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (viewModel.errorMessage != null) {
              return Center(child: Text(viewModel.errorMessage!));
            }
            if (viewModel.likedGyms.isEmpty) {
              return Center(child: Text("좋아요한 체육관이 없습니다."));
            }
            return ListView(
              children: [
                BackgroundImg(),
                SizedBox(
                  height: 270,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.likedGyms.length,
                    padding: EdgeInsets.only(left: 10),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          final gymInfo = viewModel.getGymInfoByIndex(index);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GymInfoPage(
                                roadName: gymInfo.location,
                                gymName: gymInfo.name,
                                openTime: gymInfo.facilityHours,
                              ),
                            ),
                          );
                        },
                        child: HomeCard(gymInfo: viewModel.likedGyms[index]),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                SportsSelectForm(),
                SizedBox(height: 16),
                SliderWithIndicator(),
              ],
            );
          },
        ),

        //수정 전 코드 ====>

        /*Consumer<LikedGymViewModel>(
          builder: (context, viewModel, child) {
            print("Consumer 빌드 시작");
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (viewModel.likedGyms.isEmpty) {
              return Center(child: Text("좋아요한 체육관이 없습니다."));
            }
            return ListView(
              children: [
                BackgroundImg(),
                SizedBox(
                  height: 270,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.likedGyms.length,
                    padding: EdgeInsets.only(left: 10),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // 체육관 상세 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => GymInfoPage(
                                      roadName: viewModel.likedGyms[index].location
                                      , gymName: viewModel.likedGyms[index].name
                                      , openTime: viewModel.likedGyms[index].facilityHours),
                            ),
                          );
                        },
                        child: HomeCard(gymInfo: viewModel.likedGyms[index]),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                SportsSelectForm(),
                SizedBox(height: 16),
                SliderWithIndicator(),
              ],
            );
          },
        ),*/
      ),
    );
  }
}