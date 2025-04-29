import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_credit_capstone/view_models/gym_booking_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPage extends StatefulWidget {
  final String gymId;
  final String formattedDate;
  final String selectedSport;
  final Map<String, List<String>> disabledTimes;

  PaymentPage({
    required this.gymId,
    required this.formattedDate,
    required this.selectedSport, // 선택된 종목
    required this.disabledTimes,
  });

  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  GymBookingViewModel viewModel = GymBookingViewModel();

  Map<String, dynamic>? data;
  String? selectedOption = '신용/체크카드';
  String location = "";
  bool isProcessing = false;
  int cost = 0;

  bool isLoadingCost = true; // 비용 로드 상태
  bool isLoadingLocation = true; // 도로명 로드 상태

  @override
  void initState() {
    super.initState();
    fetchCostValue(); // 비용 데이터 가져오기
    fetchLocation(); // 도로명 데이터 가져오기
  }

  // 요일을 계산하는 함수 추가
  String getDayOfWeek(String date) {
    try {
      // 날짜 문자열을 DateTime으로 변환
      DateTime parsedDate = DateTime.parse(date);

      // 요일 인덱스: 0 (일), 1 (월), ... 6 (토)
      List<String> koreanDays = ['일', '월', '화', '수', '목', '금', '토'];

      // 요일 인덱스를 기반으로 한국어 요일 반환
      return koreanDays[parsedDate.weekday % 7]; // `weekday`는 1부터 시작 (월=1, 일=7)
    } catch (e) {
      print('날짜 변환 오류: $e');
      return ''; // 변환 오류 시 빈 문자열 반환
    }
  }

  Future<Map<String, dynamic>?> getGymDataFromFirestore() async {
    // Firestore instance 초기화
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Gym_list 컬렉션에서 gymName에 해당하는 문서 참조
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await firestore.collection('Gym_list').doc(widget.gymId).get();

    // 문서 데이터 가져오기
    return documentSnapshot.data();
  }

  Future<void> fetchCostValue() async {
    try {
      Map<String, dynamic>? data = await getGymDataFromFirestore();
      if (data != null && data.containsKey('종목')) {
        Map<String, dynamic> sports = data['종목'];
        setState(() {
          cost = sports[widget.selectedSport]; // 선택된 종목 값 가져오기
          isLoadingCost = false; // 로드 완료 상태 변경
        });
      } else {
        print('문서에 "종목" 필드가 없거나 데이터가 null입니다.');
      }
    } catch (e) {
      print('비용 데이터를 가져오는 중 에러 발생: $e');
    }
  }

  Future<void> fetchLocation() async {
    try {
      Map<String, dynamic>? data = await getGymDataFromFirestore();
      if (data != null && data.containsKey('도로명')) {
        setState(() {
          location = data['도로명']; // 도로명 데이터 가져오기
          isLoadingLocation = false; // 로드 완료 상태 변경
        });
      } else {
        print('문서에 "도로명" 필드가 없거나 데이터가 null입니다.');
      }
    } catch (e) {
      print('도로명 데이터를 가져오는 중 에러 발생: $e');
    }
  }

  // 별도 함수로 로직 분리
  Future<void> _processReservation() async {
    setState(() {
      isProcessing = true;
    });

    bool isSuccessedToRes = await viewModel.saveReservation(
      widget.gymId,
      widget.disabledTimes,
      viewModel.selectedTime,
      widget.formattedDate,
    );

    setState(() {
      isProcessing = false;
    });

    print("예약 성공 여부: $isSuccessedToRes");

    if (isSuccessedToRes) {
      // 이전 페이지로 돌아가기 (뒤로가기 개념)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("예약이 완료되었습니다!")),
      );
      // 3번 뒤로가기
      popMultipleTimes(context, 3);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("예약을 완료하지 못했습니다.")),
      );
    }
  }

  void popMultipleTimes(BuildContext context, int times) {
    for (int i = 0; i < times; i++) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<GymBookingViewModel>(context, listen: false);
    String dayOfWeek = getDayOfWeek(widget.formattedDate);

    Color backgroundColor = Colors.white; // 아래 배경 색상 정의
    Color appBarColor = Colors.blue; // 버튼 색상 및 상단 색상으로 사용

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor, // 상단 색상을 배경과 동일하게
        foregroundColor: Colors.black, // 상단 글자 색상 설정
        elevation: 0, // 그림자 제거
      ),
      body: Container(
        margin: EdgeInsets.only(right: 16, left: 16),
        color: backgroundColor, // 전체 배경 색상
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('결제하기', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              SizedBox(height: 16),

              Text('체육관', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('${widget.gymId}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              // 도로명 표시
              isLoadingLocation
                  ? Text('도로명 로드 중...', style: TextStyle(fontSize: 16))
                  : Text(location ?? '데이터 없음', style: TextStyle(fontSize: 16)),

              SizedBox(height: 16),

              Divider(
                color: Colors.black.withAlpha(40),      // 라인의 색상
                thickness: 1,            // 라인의 두께
                /*indent: 0,              // 왼쪽 여백
                endIndent: 0,           // 오른쪽 여백*/
              ),
              SizedBox(height: 15),

              Text('종목', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('${widget.selectedSport}', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),

              Divider(
                color: Colors.black.withAlpha(40),      // 라인의 색상
                thickness: 1,            // 라인의 두께
                /*indent: 0,              // 왼쪽 여백
                endIndent: 0,           // 오른쪽 여백*/
              ),
              SizedBox(height: 15),

              Text('예약일자', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              //Text('${widget.formattedDate} ()', style: TextStyle(fontSize: 16)),//'2025-03-24 (월) 17:00'
              Text('${widget.formattedDate} (${dayOfWeek}) ${viewModel.selectedTime}', style: TextStyle(fontSize: 16),),
              SizedBox(height: 16),
              Text('결제수단', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),

              RadioListTile<String>(
                title: Text('신용/체크카드', style: TextStyle(fontSize: 16)),
                value: '신용/체크카드',
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
                // 왼쪽에 더 붙이도록 설정
                visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0), // 밀도를 낮추어 공간 최소화
                contentPadding: EdgeInsets.zero, // 내부 여백 제거
                controlAffinity: ListTileControlAffinity.leading, // 동그라미를 텍스트 왼쪽으로 이동
                // 선택용 동그라미 크기 수정
                activeColor: Colors.blue, // 선택된 동그라미 색상
                selectedTileColor: Colors.grey.shade200, // 선택된 타일 배경색 (선택적)
              ),
              RadioListTile<String>(
                title: Text('계좌 결제'),
                value: '계좌 결제',
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
                // 왼쪽에 더 붙이도록 설정
                visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0), // 밀도를 낮추어 공간 최소화
                contentPadding: EdgeInsets.zero, // 내부 여백 제거
                controlAffinity: ListTileControlAffinity.leading, // 동그라미를 텍스트 왼쪽으로 이동
                // 선택용 동그라미 크기 수정
                activeColor: Colors.blue, // 선택된 동그라미 색상
                selectedTileColor: Colors.grey.shade200, // 선택된 타일 배경색 (선택적)
              ),
              RadioListTile<String>(
                title: Text('카카오페이'),
                value: '카카오페이',
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
                // 왼쪽에 더 붙이도록 설정
                visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0), // 밀도를 낮추어 공간 최소화
                contentPadding: EdgeInsets.zero, // 내부 여백 제거
                controlAffinity: ListTileControlAffinity.leading, // 동그라미를 텍스트 왼쪽으로 이동
                // 선택용 동그라미 크기 수정
                activeColor: Colors.blue, // 선택된 동그라미 색상
                selectedTileColor: Colors.grey.shade200, // 선택된 타일 배경색 (선택적)
              ),
              SizedBox(height: 24),

              Divider(
                color: Colors.black.withAlpha(40),      // 라인의 색상
                thickness: 1,            // 라인의 두께
                /*indent: 0,              // 왼쪽 여백
                endIndent: 0,           // 오른쪽 여백*/
              ),
              SizedBox(height: 15),

              Center( // 결제 금액과 버튼을 중앙에 배치
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 두 텍스트를 양쪽 끝에 배치
                      children: [
                        Text(
                          '결제금액',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        isLoadingCost
                            ? Text('결제 금액 로드 중...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                            : Text('${cost ?? 0}원', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: (viewModel.selectedDate != null &&
                          viewModel.selectedTime.isNotEmpty &&
                          !isProcessing)
                          ? () async {
                        _processReservation();
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appBarColor, // 버튼 배경 색상
                        foregroundColor: Colors.white, // 버튼 글자 색상
                        padding: const EdgeInsets.symmetric(vertical: 16), // 버튼 높이
                      ),
                      child: SizedBox(
                        width: double.infinity, // 버튼 최대 너비
                        child: isLoadingCost
                            ? const Text(
                          '결제 금액 로드 중...',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        )
                            : Text(
                          '${cost ?? 0}원 결제하기',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}