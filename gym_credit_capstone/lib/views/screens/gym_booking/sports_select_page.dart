import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/data/repositories/gym_info_repository.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text("종목 선택")),
      body: availableSports.isEmpty
          ? const Center(child: CircularProgressIndicator()) // 🔹 데이터 로딩 중 표시
          : ListView.builder(
        itemCount: availableSports.length,
        itemBuilder: (context, index) {
          String sport = availableSports[index];
          return ListTile(
            title: Text(sport),
            leading: Radio<String>(
              value: sport,
              groupValue: selectedSport,
              onChanged: (value) {
                setState(() {
                  selectedSport = value;
                });
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: selectedSport == null
              ? null
              : () {
            Navigator.pop(context, selectedSport); // 🔹 선택한 값 반환 후 이전 화면으로 이동
          },
          child: const Text("선택하기"),
        ),
      ),
    );
  }

}