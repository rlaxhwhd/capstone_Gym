import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gym_credit_capstone/view_models/gym_detail_view_model.dart';
import 'package:gym_credit_capstone/views/screens/gym_detail/components/gym_header.dart';
import 'package:gym_credit_capstone/views/screens/gym_detail/components/gym_info_section.dart';
import 'package:gym_credit_capstone/views/screens/gym_detail/components/gym_tab_bar.dart';
import 'package:gym_credit_capstone/views/screens/gym_detail/components/gym_booking_button.dart';
import 'package:gym_credit_capstone/views/screens/gym_detail/components/gym_tabs/info_tab.dart';
import 'package:gym_credit_capstone/views/screens/gym_detail/components/gym_tabs/map_tab.dart';
import 'package:gym_credit_capstone/views/screens/gym_detail/components/gym_tabs/rules_tab.dart';

class GymDetailPage extends StatelessWidget {
  final String gymId;

  const GymDetailPage({super.key, required this.gymId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = GymDetailViewModel();
        viewModel.fetchGymDetail(gymId);
        return viewModel;
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: SafeArea(
            child: Consumer<GymDetailViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading || viewModel.gymInfo == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    GymHeader(
                      imageUrl: viewModel.gymInfo!.imageUrl,
                      imageHeight: MediaQuery.of(context).size.height * 0.29,
                    ),
                    GymInfoSection(gymInfo: viewModel.gymInfo!),
                    GymTabBar(),
                    Expanded(
                      child: TabBarView(
                        children: [
                          InfoTab(gymInfo: viewModel.gymInfo!), // ✅ 정보 탭
                          MapTab(
                            latitude: viewModel.gymInfo!.coord.latitude,
                            longitude: viewModel.gymInfo!.coord.longitude,
                          ), // ✅ 지도 탭
                          RulesTab(rulesData: viewModel.gymRules), // ✅ 규칙 탭
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: GymBookingButton(gymId: gymId),
          ),
        ),
      ),
    );
  }
}