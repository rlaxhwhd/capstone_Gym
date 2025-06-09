import 'package:flutter/material.dart';
import '../../../../data/models/gym_info_model.dart';
import '../../../common_widgets/tag_widget.dart';

class HomeCard extends StatelessWidget {
  final GymInfo gymInfo;

  const HomeCard({super.key, required this.gymInfo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 235,
        width: 208,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight = constraints.maxHeight * 0.65;

            return Card(
              //clipBehavior: Clip.none,
              color: Colors.white,
              elevation: 4,
             // margin: EdgeInsets.only(bottom: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    child: Image.asset(
                      gymInfo.imageUrl,
                      width: double.infinity,
                      height: imageHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        height: imageHeight,
                        child: const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gymInfo.name,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                       // const SizedBox(height: 1),
                        Text(
                          gymInfo.location,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 0.9,
                            color: Color(0xff7f7f7f),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(

                          children: [
                            Text(gymInfo.facilityHours),
                            Spacer(),
                            TagWidget.normal(gymInfo.isPaid ? "유료" : "무료", height: 17, width: 28, fontSize: 11),
                            SizedBox(width: 5),
                            TagWidget.bright(gymInfo.isMembership ? "회원제" : "비회원제", height: 17, width: 40, fontSize: 11),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
