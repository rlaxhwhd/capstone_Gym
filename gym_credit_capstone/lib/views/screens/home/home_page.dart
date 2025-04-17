import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_credit_capstone/data/repositories/gym_info_repository.dart';
import 'package:gym_credit_capstone/data/repositories/user_repository.dart';
import 'package:provider/provider.dart';
import '../../../view_models/background_view_model.dart';
import 'components/background_img.dart';
import '../../../view_models/liked_gym_view_model.dart';
import 'components/home_events_card.dart';
import 'components/sports_select_form.dart';
import 'components/sliderWithIndicator.dart';
import '../gym_detail/gym_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> selectedSports = []; // 사용자가 선택한 종목 저장

  void _updateSelectedSports(List<String> sports) {
    setState(() {
      selectedSports = sports; // 사용자가 선택한 종목 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    // 상단바 설정을 한 번만 적용
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // edge-to-edge 모드 설정
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BackgroundViewModel()),
        ChangeNotifierProvider(
          create: (_) => LikedGymViewModel(
            userRepository: UserRepository(),
            gymInfoRepository: GymInfoRepository(),
          )..fetchLikedGyms(),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        // 투명한 AppBar 추가
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
          ),
        ),
        body: Consumer<LikedGymViewModel>(
          builder: (context, viewModel, child) {
            print("Consumer 빌드 시작");
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (viewModel.likedGyms.isEmpty) {
              return Center(child: Text("좋아요한 체육관이 없습니다."));
            }
            return SafeArea(
              top: false, // 상단 SafeArea 비활성화하여 콘텐츠가 상단까지 차지하도록 함
              child: RefreshIndicator(
                onRefresh: () async {
                  await viewModel.fetchLikedGyms();
                },
                child: ListView(
                  children: [
                    BackgroundImg(),
                    SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // 내부 내용 만큼만 공간을 차지
                        children: [
                          // 텍스트 영역: 필요에 따라 위쪽 패딩을 조정
                          Padding(
                            padding: const EdgeInsets.only(left: 28, top: 16),
                            child: Row(
                              children: [
                                Text(
                                  "즐겨찾기한 체육관",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: "NanumGothic",
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Tooltip(
                                  message: '자주 가는 체육관을 빠르게 볼 수 있어요',
                                  child: Icon(
                                    Icons.info_outline,
                                    size: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 텍스트와 카드 사이의 간격을 최소화
                          const SizedBox(height: 8),
                          // 카드 리스트 영역: 카드 위젯(HomeCard)의 높이에 맞게 SizedBox 사용
                          SizedBox(
                            // 예를 들어 HomeCard의 높이를 240로 지정했으므로 그대로 사용
                            height: 240,
                            child: ListView.builder(
                              clipBehavior: Clip.none,
                              scrollDirection: Axis.horizontal,
                              itemCount: viewModel.likedGyms.length,
                              padding: const EdgeInsets.only(left: 28),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      // 사용자가 선택한 종목 전달
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => GymDetailPage(
                                            gymId: viewModel.likedGyms[index].name, // 선택된 체육관 ID 전달
                                          ),
                                        ),
                                      );
                                    },
                                    child: HomeCard(
                                      gymInfo: viewModel.likedGyms[index],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    SportsSelectForm(), // 종목 선택 컴포넌트 추가
                    SizedBox(height: 16),
                    SliderWithIndicator(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}