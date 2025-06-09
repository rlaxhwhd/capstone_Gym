import 'package:flutter/material.dart';
import 'package:gym_credit_capstone/view_models/identity_verification_view_model.dart';
import 'package:gym_credit_capstone/style/custom_colors.dart';

class MobileCarrierPicker extends StatelessWidget {
  final IdentityVerificationViewModel viewModel;

  const MobileCarrierPicker({required this.viewModel, super.key});

  @override
  Widget build(BuildContext context) {
    final carriers = ['SKT', 'KT', 'LG U+'];

    if (viewModel.currentPageIndex ==0){
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              '이용 중인 통신사를\n선택해 주세요.',
              style: TextStyle(
                fontSize: 30,
                fontFamily: 'NanumSquare',
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              '알뜰폰이라면 알뜰폰 사업자를 선택해주세요.',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'NanumSquare',
                fontWeight: FontWeight.w500,
                color: Color(0xff9f9f9f),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,

              children:
                  carriers.map((carrier) {
                    final isSelected = viewModel.selectedCarrier == carrier;
                    final Map<String, String> carriersPath = {
                      'SKT': 'assets/images/mobile_carriers/SKT_Logo.png',
                      'KT': 'assets/images/mobile_carriers/KT_Logo.png',
                      'LG U+': 'assets/images/mobile_carriers/LGU_Logo.png',
                    };
                    return GestureDetector(
                      onTap: () => viewModel.selectCarrier(carrier),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                isSelected
                                    ? CustomColors.primaryColor.withOpacity(0.5)
                                    : Colors.grey.withOpacity(0.3),
                            width: 1.7,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: CustomColors.primaryColor.withOpacity(
                                  0.5,
                                ),
                                // 그림자 색상 및 투명도
                                spreadRadius: 1,
                                // 그림자가 퍼지는 정도
                                blurRadius: 3,
                                // 그림자의 흐림 정도
                                offset: const Offset(
                                  0,
                                  0,
                                ), // 그림자의 위치 (가로, 세로) - 아래로 3픽셀 이동
                              ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            carriersPath[carrier]!,
                            width: 50,
                            height: 50,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            /*const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: carriers.map((carrier) {
                  return Text(carrier, style: TextStyle());
            }).toList(),
          ),*/
            Text('알뜰폰 사업자 목록'),
          ],
        ),
      );}
    else {
      return Container();
    }
  }
}
