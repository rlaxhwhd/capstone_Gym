import 'package:flutter/material.dart';
import '../../../../data/models/gym_info_model.dart';
import 'package:intl/intl.dart';

class HomeCard extends StatelessWidget {
  final GymInfo gymInfo;

  const HomeCard({super.key, required this.gymInfo});

  @override
  Widget build(BuildContext context) {
    return Center(
      // HomeCard의 부모에서 카드 자체를 가운데 정렬
      child: SizedBox(
        height: 250,
        width: 270,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
              children: [
                // 이미지 추가
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: Image.asset(
                    gymInfo.imageUrl,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 텍스트 왼쪽 정렬
                    children: [
                      Text(
                        gymInfo.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 0),
                      Text(
                        gymInfo.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xff7f7f7f),
                        ),
                      ),
                      Row(
                        children: [
                          Text.rich(
                            TextSpan(
                              text: NumberFormat("#,###").format(gymInfo.sports.values.first),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Color(0xff7f7f7f),
                              ),
                              children: [
                                TextSpan(
                                  text: ' 원',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 70),
                            child: DefaultTextStyle(
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xff7f7f7f),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [Text(gymInfo.isPaid?"유료":"무료"), Text(gymInfo.isMembership?"회원제":"비회원제")],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
