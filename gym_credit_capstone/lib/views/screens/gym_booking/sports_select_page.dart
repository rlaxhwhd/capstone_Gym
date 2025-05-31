import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/data/repositories/gym_info_repository.dart';
import 'package:gym_credit_capstone/views/screens/home/components/sports_select_form.dart';
import 'package:gym_credit_capstone/views/common_widgets/custom_back_button.dart';
import 'package:gym_credit_capstone/data/repositories/sports_select_repository.dart';

class SportsSelectionPage extends StatefulWidget {
  final String gymId;

  const SportsSelectionPage({super.key, required this.gymId});

  @override
  State<SportsSelectionPage> createState() => _SportsSelectionPageState();
}

class _SportsSelectionPageState extends State<SportsSelectionPage> {
  List<String> availableSports = [];
  String? selectedSport;
  Map<String, int> targetPrice = {};
  bool isLoaded = false;
  int priceLoadCount = 0;
  final GymInfoRepository _model = GymInfoRepository();
  SportsSelectionFormState ssf = SportsSelectionFormState();
  SportsSelectRepository ssr = SportsSelectRepository();

  @override
  void initState() {
    super.initState();
    fetchSports();
  }

  Future<void> loadSportPrices(String sport, int index) async {
    int price = await ssr.fetchSportMap(widget.gymId, sport);

    //print("작동하기");

    if(!isLoaded) {
      setState(() {
        targetPrice[sport] = price;
        priceLoadCount++;

        if(priceLoadCount >= availableSports.length) {
          isLoaded = true;
        }
      });
    }
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
              margin: EdgeInsets.only(left: screenWidth * 0.1, top: 110),
              shadowColor: Colors.white.withAlpha(0),
              color: Colors.white.withAlpha(0),
              child: Text(widget.gymId, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),),
            ),
            Card(
              margin: EdgeInsets.only(left: screenWidth * 0.1, top: 170),
              shadowColor: Colors.white.withAlpha(0),
              color: Colors.white.withAlpha(0),
              child: Text("종목선택", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),),
            ),
            Card(
              margin: EdgeInsets.only(top: 200),
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
                          loadSportPrices(sport, index);

                          if(!isLoaded) {
                            return Center(child: CircularProgressIndicator());
                          }
                          else {return GestureDetector(
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
                                    Text("${targetPrice[sport].toString()}원"),
                                  ]
                              ),
                            ),
                          );
                          }
                        },
                      ),
                    ],
                  )
              ),
            )
          ],
        )
    );
  }
}