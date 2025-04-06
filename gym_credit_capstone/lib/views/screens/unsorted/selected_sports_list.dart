import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_credit_capstone/view_models/filtered_gym_view_model.dart';

class SelectedSportsList extends StatefulWidget {
  final List<String> selectedSports;

  SelectedSportsList({Key? key, required this.selectedSports}) : super(key: key);

  @override
  _SelectedSportsListState createState() => _SelectedSportsListState();
}

class _SelectedSportsListState extends State<SelectedSportsList> {
  String? selectedOption; // 현재 선택된 필터 옵션
  String filterText = "해당 없음"; // 버튼 텍스트 기본값

  @override
  void initState() {
    super.initState();
    _loadFilteredGyms(); // 초기 데이터 로드
  }

  Future<void> _loadFilteredGyms() async {
    await context.read<FilteredGymViewModel>().filterGymsBySports(
        widget.selectedSports);
  }

  void onOptionSelected(String? option) {
    setState(() {
      selectedOption = option;
      filterText = option ?? "해당 없음";
    });
    print("선택된 필터 옵션: ${selectedOption ?? "해당 없음"}");
  }

  @override
  Widget build(BuildContext context) {
    // 필터링된 체육관 리스트를 ViewModel에서 가져오기
    return Builder(
      builder: (context) {
        final filteredGyms = context
            .watch<FilteredGymViewModel>()
            .filteredGyms;

        return Scaffold(
          appBar: AppBar(title: const Text("선택한 스포츠")),
          body: Column(
            children: [
              // 필터 옵션 버튼
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: () async {
                    final option = await showModalBottomSheet<String>(
                      context: context,
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text("무료"),
                              onTap: () => Navigator.pop(context, "무료"),
                            ),
                            ListTile(
                              title: const Text("유료"),
                              onTap: () => Navigator.pop(context, "유료"),
                            ),
                            ListTile(
                              title: const Text("해당 없음"),
                              onTap: () => Navigator.pop(context, null),
                            ),
                          ],
                        );
                      },
                    );
                    onOptionSelected(option);
                  },
                  child: Text("무료/유료: $filterText"),
                ),
              ),
              // 필터링된 체육관 표시
              Expanded(
                child: ListView.builder(
                  itemCount: filteredGyms.length,
                  itemBuilder: (context, index) {
                    final gym = filteredGyms[index];

                    // 선택된 필터 옵션에 따라 표시
                    if (selectedOption == "무료" && gym.isPaid == true) {
                      return Container(); // 유료인 경우 필터링 제외
                    }
                    if (selectedOption == "유료" && gym.isPaid == false) {
                      return Container(); // 무료인 경우 필터링 제외
                    }

                    return ListTile(
                      title: Text(gym.name),
                      subtitle: Text("요금: ${gym.isPaid ? '유료' : '무료'}"),
                      onTap: () {
                        print("testing");
                        /*Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GymInfoPage(
                            roadName: gym.location ?? "정보 없음",
                            gymName: gym.name,
                            openTime: gym.facilityHours ?? "정보 없음",
                          ),
                        ),
                      );*/
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}