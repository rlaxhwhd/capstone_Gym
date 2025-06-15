import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../view_models/usage_history_viewmodel.dart';
import 'pickdate.dart';

class UsageHistoryFilterSheet extends StatelessWidget {
  final VoidCallback? onClose;
  const UsageHistoryFilterSheet({super.key, this.onClose});

  String _format(DateTime? d) =>
      d == null ? '--' : DateFormat('yyyy-MM-dd').format(d);

  static const Map<String, String> _sportsTranslation = {
    '전체': '전체',
    '축구장': 'SCCR',
    '농구장': 'BKB',
    '배드민턴장': 'BMT',
    '테니스장': 'TNS',
    '탁구장': 'TBTNS',
    '야구장': 'BSB',
    '풋살장': 'FTS',
    '수영장': 'PL',
    '골프장': 'GLF',
  };

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UsageHistoryViewModel>();

    final categoryOptions = _sportsTranslation.keys.toList();
    const paymentOptions = ['전체', '신용/체크카드', '카카오페이', '계좌', '그 외 결제수단'];

    final start = viewModel.startDate;
    final end = viewModel.endDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 기간 버튼
        Row(
          children: ['1개월', '1년', '기간 설정'].map((label) {
            final isSelected = viewModel.selectedPeriod == label;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: OutlinedButton(
                  onPressed: () => viewModel.updatePeriod(label),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: isSelected ? const Color(0xff69B7FF) : Colors.white,
                    foregroundColor: isSelected ? Colors.white : Colors.black,
                    side: BorderSide(
                      color: isSelected ? const Color(0xff69B7FF) : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(label),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // 날짜 선택
        Row(
          children: [
            _DateField(
              label: _format(start),
              enabled: viewModel.selectedPeriod == '기간 설정',
              onTap: () => _pickDate(context, isStart: true),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('~'),
            ),
            _DateField(
              label: _format(end),
              enabled: viewModel.selectedPeriod == '기간 설정',
              onTap: () => _pickDate(context, isStart: false),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 드롭다운 (종목 / 결제)
        Row(
          children: [
            // 종목
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _sportsTranslation.entries
                    .firstWhere((e) => e.value == viewModel.selectedCategory,
                    orElse: () => const MapEntry('전체', '전체'))
                    .key,
                items: categoryOptions
                    .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    final code = _sportsTranslation[val]!;
                    viewModel.updateCategory(code);
                  }
                },
                decoration: const InputDecoration(
                  labelText: '종목',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 결제 수단
            Expanded(
              child: DropdownButtonFormField<String>(
                value: viewModel.selectedPayment,
                items: paymentOptions
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) viewModel.updatePayment(val);
                },
                decoration: const InputDecoration(
                  labelText: '결제 수단',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // 조회 버튼
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              viewModel.fetchUsageData();
              onClose?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff69B7FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text(
              '조회',
              style: TextStyle(fontSize: 17,  fontWeight: FontWeight.bold,color: Colors.white,),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final viewModel = context.read<UsageHistoryViewModel>();
    final initial = isStart ? viewModel.startDate : viewModel.endDate;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => PickDatePicker(
        initialDate: initial,
        onConfirm: (picked) {
          final start = isStart ? picked : viewModel.startDate;
          final end = isStart ? viewModel.endDate : picked;
          viewModel.updateDateRange(start, end);
        },
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const _DateField({
    required this.label,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled ? Colors.grey.shade400 : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.black87 : Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
