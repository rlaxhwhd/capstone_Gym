import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_credit_capstone/views/common_widgets/custom_back_button.dart';
import 'package:gym_credit_capstone/view_models/gym_booking_view_model.dart';
import 'package:gym_credit_capstone/view_models/payment_view_model.dart';
import 'package:gym_credit_capstone/data/repositories/gym_Info_repository.dart';
import 'package:gym_credit_capstone/utils/date_calculator.dart';

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
  PaymentViewModel paymentViewModel = PaymentViewModel();
  GymInfoRepository repository = GymInfoRepository();
  DateCalculator dateUtils = DateCalculator();

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
    fetchCostValue();
    fetchLocation();
  }

  Future<void> fetchCostValue() async {
    try {
      int fetchedCost = await paymentViewModel.fetchCost(widget.gymId, widget.selectedSport);
      setState(() {
        cost = fetchedCost;
        isLoadingCost = false;
      });
    } catch (e) {
      print('Error fetching cost: $e');
    }
  }

  Future<void> fetchLocation() async {
    try {
      String fetchedLocation = await paymentViewModel.fetchLocation(widget.gymId);
      setState(() {
        location = fetchedLocation;
        isLoadingLocation = false;
      });
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  Future<void> _processReservation() async {
    setState(() {
      isProcessing = true;
    });

    bool isSuccess = await viewModel.saveReservation(
      widget.gymId,
      widget.disabledTimes,
      viewModel.selectedTime,
      widget.formattedDate,
    );

    setState(() {
      isProcessing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isSuccess ? "예약이 완료되었습니다!" : "예약을 완료하지 못했습니다.")),
    );

    if (isSuccess) {
      popMultipleTimes(context, 3);
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
    String dayOfWeek = dateUtils.getDayOfWeek(widget.formattedDate);

    Color backgroundColor = Colors.white; // 아래 배경 색상 정의
    Color appBarColor = Colors.lightBlueAccent; // 버튼 색상 및 상단 색상으로 사용

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(right: 16, left: 16),
        color: backgroundColor, // 전체 배경 색상
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 32),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 26,
                child: CustomBackButton(),
              ),
              SizedBox(height: 24),
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
                activeColor: Colors.lightBlueAccent, // 선택된 동그라미 색상
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
                activeColor: Colors.lightBlueAccent, // 선택된 동그라미 색상
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
                activeColor: Colors.lightBlueAccent, // 선택된 동그라미 색상
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