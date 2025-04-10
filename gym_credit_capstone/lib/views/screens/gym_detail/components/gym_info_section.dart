import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/gym_info_model.dart';
import '../../../../view_models/gym_detail_view_model.dart';

import '../../../common_widgets/tag_widget.dart';
import '../../../common_widgets/round_button_style.dart';

class GymInfoSection extends StatelessWidget {
  final GymInfo gymInfo;

  const GymInfoSection({super.key, required this.gymInfo});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GymDetailViewModel>();

    return Container(
      height: 160,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 14, 28, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TagWidget.bright(gymInfo.isMembership ? "회원제" : "비회원제"),
                const SizedBox(width: 5),
                TagWidget.normal(gymInfo.isPaid ? "유료" : "무료"),
                const Spacer(),
                RoundButtonStyle(
                  child: IconButton(
                    icon: Icon(
                      viewModel.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: const Color(0xff69B7FF),
                    ),
                    onPressed: () {
                      viewModel.toggleFavoriteGym(gymInfo.name);
                    },
                  ),
                ),
              ],
            ),
            Text(
              gymInfo.name,
              style: const TextStyle(
                color: Color(0xFF191919),
                fontSize: 28,
                fontFamily: 'nanumgothic',
                fontWeight: FontWeight.w400,
              ),
            ),
            DefaultTextStyle(
              style: const TextStyle(
                color: Color(0xFF4B4D4F),
                fontSize: 18,
                fontFamily: 'nanumgothic',
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gymInfo.location),
                  Text(viewModel.formattedDistance),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}