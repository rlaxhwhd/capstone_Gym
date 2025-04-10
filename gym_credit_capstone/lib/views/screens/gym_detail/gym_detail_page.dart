import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_credit_capstone/view_models/gym_detail_view_model.dart';

import 'components/gym_header.dart';
import 'components/gym_info_section.dart';
import 'components/gym_tab_bar.dart';
import 'components/gym_tabs/info_tab.dart';
import 'components/gym_tabs/map_tab.dart';
import 'components/gym_tabs/rules_tab.dart';
import 'components/gym_booking_button.dart';

class GymDetailPage extends StatelessWidget {
  final String gymName;

  const GymDetailPage({super.key, required this.gymName});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = GymDetailViewModel();
        viewModel.fetchGymDetail(gymName);
        return viewModel;
      },
      child: Scaffold(
        body: Consumer<GymDetailViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading || viewModel.gymInfo == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final gym = viewModel.gymInfo!;
            final imageHeight = screenHeight * 0.29;

            return DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  GymHeader(imageUrl: gym.imageUrl, imageHeight: imageHeight),
                  GymInfoSection(gymInfo: gym),
                  GymTabBar(),
                  Expanded(
                    child: TabBarView(
                      children: [
                        InfoTab(gymInfo: gym),
                        MapTab(
                          latitude: gym.coord.latitude,
                          longitude: gym.coord.longitude,
                        ),
                        RulesTab(rulesData: viewModel.gymRules),
                      ],
                    ),
                  ),
                  GymBookingButton(gymId: gym.name,),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
