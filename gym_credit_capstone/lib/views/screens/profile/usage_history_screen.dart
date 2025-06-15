import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../common_widgets/Filtersheet.dart';
import '../../common_widgets/custom_back_button.dart';
import '../../../view_models/usage_history_viewmodel.dart';

class UsageHistoryScreen extends StatelessWidget {
  const UsageHistoryScreen({super.key});

  String formatCurrency(int amount) =>
      NumberFormat.currency(locale: 'ko_KR', symbol: '').format(amount);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UsageHistoryViewModel()..fetchUsageData(),
      child: const _UsageHistoryView(),
    );
  }
}

class _UsageHistoryView extends StatefulWidget {
  const _UsageHistoryView({super.key});

  @override
  State<_UsageHistoryView> createState() => _UsageHistoryViewState();
}

class _UsageHistoryViewState extends State<_UsageHistoryView>
    with TickerProviderStateMixin {
  bool showFilter = false;

  String formatCurrency(int amount) =>
      NumberFormat.currency(locale: 'ko_KR', symbol: '').format(amount);
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UsageHistoryViewModel>();
    final usageList = viewModel.usageList;

    final dateRangeStr =
        '${DateFormat('yyyy.MM.dd').format(viewModel.startDate)} ~ ${DateFormat('yyyy.MM.dd').format(viewModel.endDate)}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomBackButton(),
              const SizedBox(height: 12),
              const Text('이용내역',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // 날짜 필터
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('전체', style: TextStyle(fontSize: 15)),
                  GestureDetector(
                    onTap: () {
                      setState(() => showFilter = !showFilter);
                    },
                    child: Row(
                      children: [
                        Text(dateRangeStr,
                            style: const TextStyle(fontSize: 15)),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: showFilter ? 0.5 : 0,
                          child: const Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                reverseDuration: const Duration(milliseconds: 200),
                child: showFilter
                    ? UsageHistoryFilterSheet(
                  onClose: () => setState(() => showFilter = false),
                )
                    : const SizedBox.shrink(),
              ),
              if (showFilter) const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('총 ${viewModel.totalCount}건',
                      style: const TextStyle(
                          color: Color(0xff69B7FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                  Text('사용 합계 ${formatCurrency(viewModel.totalAmount)}원',
                      style: const TextStyle(
                          color: Color(0xff69B7FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 20),

              Expanded(
                child: usageList.isEmpty
                    ? const Center(
                  child: Text('조회 결과가 없습니다.',
                      style:
                      TextStyle(color: Colors.grey, fontSize: 15)),
                )
                    : ListView.separated(
                  itemCount: usageList.length,
                  separatorBuilder: (_, __) =>
                  const Divider(height: 20),
                  itemBuilder: (context, index) {
                    final item = usageList[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.gym,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('${item.date} ${item.time}  |  ${item.sports}',
                            style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('${formatCurrency(item.amount)}원',
                            style: const TextStyle(
                                color: Color(0xff69B7FF),
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
