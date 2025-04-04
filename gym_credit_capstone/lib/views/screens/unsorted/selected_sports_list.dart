import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../screens/unsorted/gym_info_page.dart';

class SelectedSportsList extends StatefulWidget {
  final List<String> selectedSports;

  SelectedSportsList({Key? key, required this.selectedSports}) : super(key: key);

  @override
  _SelectedSportsListState createState() => _SelectedSportsListState();
}

class _SelectedSportsListState extends State<SelectedSportsList> {
  String? selectedOption = null; // 기본 필터를 "해당 없음"으로 설정
  String filterText = "해당 없음"; // 버튼 텍스트의 기본값

  // 옵션을 선택할 때 실행
  void onOptionSelected(String? option) {
    setState(() {
      selectedOption = option;
      filterText = option ?? "해당 없음"; // 옵션 선택에 따라 텍스트 변경
    });
    print("선택된 필터 옵션: ${selectedOption ?? "해당 없음"}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("선택한 스포츠")),
      body: Column(
        children: [
          // 상단에 하나의 버튼 추가
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
                          title: Text("무료"),
                          onTap: () => Navigator.pop(context, "무료"),
                        ),
                        ListTile(
                          title: Text("유료"),
                          onTap: () => Navigator.pop(context, "유료"),
                        ),
                        ListTile(
                          title: Text("해당 없음"),
                          onTap: () => Navigator.pop(context, null),
                        ),
                      ],
                    );
                  },
                );
                onOptionSelected(option);
              },
              child: Text("무료/유료: $filterText"), // 초기 텍스트는 "해당 없음"
            ),
          ),
          // StreamBuilder로 체육관 리스트 표시
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Gym_list').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // 필터링된 체육관 리스트
                final filteredDocs = docs.where((doc) {
                  final bool? isPaid = doc['유료']; // '유료' 필드 기반 필터링
                  if (selectedOption == "무료") {
                    return isPaid == false;
                  } else if (selectedOption == "유료") {
                    return isPaid == true;
                  }
                  return true; // "해당 없음"인 경우 모두 포함
                }).toList();

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];

                    if (doc.exists) {
                      final String gymName = doc.id;

                      return ListTile(
                        title: Text(gymName),
                        subtitle: Text("요금: ${doc['유료'] == true ? '유료' : '무료'}"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GymInfoPage(
                                roadName: doc['도로명'] ?? "정보 없음",
                                gymName: gymName,
                                openTime: doc['운영시간'] ?? "정보 없음",
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return Container();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}