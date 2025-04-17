import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_credit_capstone/view_models/selected_sports_list_view_model.dart';
import 'package:gym_credit_capstone/views/screens/gym_detail/gym_detail_page.dart';
import 'package:gym_credit_capstone/views/common_widgets/custom_back_button.dart';

class SelectedSportsList extends StatefulWidget {
  final List<String> selectedSports;

  const SelectedSportsList({Key? key, required this.selectedSports}) : super(key: key);

  @override
  State<SelectedSportsList> createState() => _SelectedSportsListState();
}

class _SelectedSportsListState extends State<SelectedSportsList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SelectedSportsListViewModel>().fetchGymList(widget.selectedSports);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Consumer<SelectedSportsListViewModel>(
        builder: (context, viewModel, _) {
          final gyms = viewModel.filteredGyms;

          return Stack(
            children: [
              Positioned(
                left: screenWidth * 0.07,
                top: screenHeight * 0.05,
                child: const CustomBackButton(),
              ),
              Positioned(
                left: screenWidth * 0.07,
                top: screenHeight * 0.18,
                child: const Text(
                  '보유한 체육관',
                  style: TextStyle(
                    color: Color(0xFF191919),
                    fontSize: 20,
                    fontFamily: 'NanumSquare',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Positioned(
                left: screenWidth * 0.07,
                top: screenHeight * 0.24,
                right: screenWidth * 0.07,
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: widget.selectedSports.map((sport) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F3FF),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        sport,
                        style: TextStyle(
                          color: const Color(0xFF69B7FF),
                          fontSize: screenWidth * 0.032,
                          fontFamily: 'NanumSquare',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Positioned(
                right: screenWidth * 0.07,
                top: screenHeight * 0.29,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        viewModel.toggleFreeFilter();
                      },
                      child: Text(
                        '무료',
                        style: TextStyle(
                          color: viewModel.isFreeSelected ? Colors.blue : const Color(0xFFA6A6A6),
                          fontSize: 14,
                          fontFamily: 'NanumSquare',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        viewModel.toggleReservableFilter();
                      },
                      child: Text(
                        '예약가능',
                        style: TextStyle(
                          color: viewModel.isReservableSelected ? Colors.blue : const Color(0xFFA6A6A6),
                          fontSize: 14,
                          fontFamily: 'NanumSquare',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: screenWidth * 0.07,
                top: screenHeight * 0.35,
                right: screenWidth * 0.07,
                bottom: 0,
                child: gyms.isEmpty
                    ? const Center(
                  child: Text(
                    '해당 조건의 체육관이 없습니다.',
                    style: TextStyle(
                      color: Color(0xFF191919),
                      fontSize: 16,
                      fontFamily: 'NanumSquare',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: gyms.length,
                  itemBuilder: (context, index) {
                    final gym = gyms[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GymDetailPage(
                              gymId: gym.name, // 선택된 체육관 ID 전달
                            ),
                          ),
                        );
                      },
                      child: GymListItem(
                        name: gym.name,
                        address: gym.location,
                        distance: "현 위치로부터 계산 중",
                        isPaid: gym.isPaid,
                        isReservable: true,
                        imageUrl: gym.imageUrl,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// 체육관 리스트 아이템 위젯 (변경 없음)
class GymListItem extends StatelessWidget {
  final String name;
  final String address;
  final String distance;
  final bool isPaid;
  final bool isReservable;
  final String imageUrl;

  const GymListItem({
    Key? key,
    required this.name,
    required this.address,
    required this.distance,
    required this.isPaid,
    required this.isReservable,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 145,
              height: 93,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$name\n',
                          style: const TextStyle(
                            color: Color(0xFF191919),
                            fontSize: 14,
                            fontFamily: 'NanumSquare',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: '$address\n$distance',
                          style: const TextStyle(
                            color: Color(0xFF191919),
                            fontSize: 14,
                            fontFamily: 'NanumSquare',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 43,
                        height: 23,
                        decoration: BoxDecoration(
                          color: const Color(0xFF69B7FF),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isPaid ? '유료' : '무료',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'NanumSquare',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 62,
                        height: 23,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F3FF),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          '예약가능',
                          style: TextStyle(
                            color: Color(0xFF69B7FF),
                            fontSize: 12,
                            fontFamily: 'NanumSquare',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
