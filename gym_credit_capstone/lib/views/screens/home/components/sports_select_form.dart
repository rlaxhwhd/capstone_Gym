import 'package:flutter/material.dart';
import '../../unsorted/selected_sports_list.dart'; // 선택한 스포츠를 보여줄 페이지 import
import 'package:gym_credit_capstone/style/custom_colors.dart';

class SportsSelectForm extends StatefulWidget {
  @override
  SportsSelectionFormState createState() => SportsSelectionFormState();
}

class SportsSelectionFormState extends State<SportsSelectForm> {
  final List<Map<String, IconData>> sports = [
    {'축구장': Icons.sports_soccer},
    {'테니스장': Icons.sports_tennis},
    {'탁구장': Icons.sports_handball},
    {'골프장': Icons.sports_golf},
    {'야구장': Icons.sports_baseball},
    {'배구장': Icons.sports_volleyball},
    {'족구장': Icons.sports_football},
    {'풋살장': Icons.sports_soccer_outlined},
  ];

  final Map<String, IconData> sportsMap =
    {
      '축구장': Icons.sports_soccer,
      '테니스장': Icons.sports_tennis,
      '탁구장': Icons.sports_handball,
      '골프장': Icons.sports_golf,
      '야구장': Icons.sports_baseball,
      '배구장': Icons.sports_volleyball,
      '족구장': Icons.sports_football,
      '풋살장': Icons.sports_soccer_outlined
    };

  final Set<String> selectedSports = {}; // 선택된 스포츠 저장

  void _toggleSelection(String sport) {
    setState(() {
      if (selectedSports.contains(sport)) {
        selectedSports.remove(sport);
      } else {
        selectedSports.add(sport);
      }
    });
  }

  void _onSearch() {
    // 선택한 스포츠 리스트를 다음 페이지로 전달
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SelectedSportsList(selectedSports: selectedSports.toList()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 스포츠 선택 문구 + 찾기 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "원하는 스포츠 선택하기\n",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          fontFamily: "NanumSquare"),
                    ),
                    TextSpan(
                      text: "근처에 이용가능한 체육관들을 확인해보세요!",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: "NanumSquare"),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _onSearch,
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero), // 패딩 제거
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
                  children: [
                    const Text(
                      "찾기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: "NanumSquare",
                        color: CustomColors.primaryColor
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 아이콘 버튼 리스트
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50), // 좌우 여백 50 추가
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // 부모 스크롤 사용
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 한 줄에 4개씩
              crossAxisSpacing: 30,
              mainAxisSpacing: 40,
              childAspectRatio: 0.67, // 텍스트를 위한 공간 확보를 위해 비율 조정
            ),
            itemCount: sports.length,
            itemBuilder: (context, index) {
              String name = sports[index].keys.first;
              IconData icon = sports[index].values.first;
              bool isSelected = selectedSports.contains(name);

              return GestureDetector(
                onTap: () => _toggleSelection(name),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Color(0xff69b7ff) : Color(0xffF3F5F7),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.5),
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            size: 35,
                            color: isSelected ? Colors.white : Color(0xffB1B3B5),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10), // 아이콘과 텍스트 사이 간격
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Color(0xff69b7ff) : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}