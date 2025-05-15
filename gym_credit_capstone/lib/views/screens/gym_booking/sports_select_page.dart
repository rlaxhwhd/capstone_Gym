import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/data/repositories/gym_info_repository.dart';
import 'package:gym_credit_capstone/views/screens/home/components/sports_select_form.dart';
import 'package:gym_credit_capstone/views/common_widgets/custom_back_button.dart';

class SportsSelectionPage extends StatefulWidget {
  final String gymId;

  const SportsSelectionPage({super.key, required this.gymId});

  @override
  State<SportsSelectionPage> createState() => _SportsSelectionPageState();
}

class _SportsSelectionPageState extends State<SportsSelectionPage> {
  List<String> availableSports = [];
  String? selectedSport;
  final GymInfoRepository _model = GymInfoRepository();
  SportsSelectionFormState ssf = SportsSelectionFormState();

  @override
  void initState() {
    super.initState();
    fetchSports();
  }

  Future<void> fetchSports() async {
    List<String> sports = await _model.fetchGymSports(widget.gymId);
    setState(() {
      availableSports = sports;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Card(
            margin: EdgeInsets.only(left: screenWidth * 0.1, top: 50),
            shadowColor: Colors.white.withAlpha(0),
            color: Colors.white.withAlpha(0),
            child: Positioned(
              child: CustomBackButton(),
            ),
          ),
          Card(
            margin: EdgeInsets.only(left: screenWidth * 0.1, top: 50),
            shadowColor: Colors.white.withAlpha(0),
            color: Colors.white.withAlpha(0),
            child: Text(widget.gymId, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),),
          ),
          Card(
            margin: EdgeInsets.only(left: screenWidth * 0.1, top: 110),
            shadowColor: Colors.white.withAlpha(0),
            color: Colors.white.withAlpha(0),
            child: Text("종목선택", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),),
          ),
          Card(
            margin: EdgeInsets.only(top: 140),
            color:Colors.white,
            shadowColor: Colors.white.withAlpha(0),
            child: availableSports.isEmpty
                ? const Center(child: CircularProgressIndicator()) // 데이터 로딩 중 표시
                : Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
                child: Stack(
                  children: [
                    GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 2열 구조
                        childAspectRatio: 1, // 적절한 비율 설정
                      ),
                      itemCount: availableSports.length,
                      itemBuilder: (context, index) {
                        String sport = availableSports[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSport = sport;
                            });
                          },
                          child: Card(
                            shadowColor: Colors.white.withAlpha(0),
                            color: Colors.white,
                            margin: EdgeInsets.only(right:20, left:20),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context, sport); // 선택된 종목을 반환
                                    },
                                    child: SizedBox(
                                      height: 70, width: 70,
                                      child: Card(
                                        color: Colors.lightBlueAccent,
                                        child: Icon(
                                          ssf.sportsMap[sport] ?? Icons.sports, // 종목에 맞는 아이콘 표시
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    sport,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text("3,000원"),
                                ]
                              /*children: [
                                SizedBox(
                                  height: 70, width: 70,
                                  child: Card(
                                    color: Colors.lightBlueAccent,
                                    child: Icon(
                                      ssf.sportsMap[sport] ?? Icons.sports, // 종목에 맞는 아이콘 표시
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  sport,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text("3,000원"),
                              ],*/
                            ),
                          ),
                        );
                      },
                    ),
                    /*Column(
                      mainAxisAlignment: MainAxisAlignment.end, // 화면 하단에 배치
                      children: [
                        Card(
                          shadowColor: Colors.white.withAlpha(0),
                          margin: EdgeInsets.only(left: screenWidth / 100 * 33.5, bottom: 20),
                          child: ElevatedButton(
                            onPressed: selectedSport == null
                                ? null
                                : () {
                              Navigator.pop(context, selectedSport); // 선택한 값 반환 후 이전 화면으로 이동
                            },
                            child: const Text("선택하기"),
                          ),
                        ),
                      ],
                    )*/
                  ],
                )
            ),
          )
        ],
      )
    );
  }
}