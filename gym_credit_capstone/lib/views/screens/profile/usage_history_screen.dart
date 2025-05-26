import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../common_widgets/custom_back_button.dart';
import '../../common_widgets/tag_widget.dart';

class UsageHistoryScreen extends StatefulWidget {
  const UsageHistoryScreen({super.key});

  @override
  State<UsageHistoryScreen> createState() => _UsageHistoryScreenState();
}

class _UsageHistoryScreenState extends State<UsageHistoryScreen> {
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  int totalCount = 0;
  int totalAmount = 0;
  List<Map<String, dynamic>> usageList = [];

  bool hasSelectedDate = false;

  Future<void> fetchUsageData() async {
    final snapshot = await FirebaseFirestore.instance.collection('reservations').get();

    int count = 0;
    int sum = 0;
    List<Map<String, dynamic>> tempList = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final dateString = data['date'] as String?;
      if (dateString == null) continue;

      final date = DateTime.tryParse(dateString);
      if (date != null &&
          date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          date.isBefore(endDate.add(const Duration(days: 1)))) {
        int itemTotal = 0;
        String? sportName;
        String? time = data['time']?.toString();

        if (data['sports'] != null && data['sports'] is Map<String, dynamic>) {
          final sports = data['sports'] as Map<String, dynamic>;
          final price = sports['price'];
          sportName = sports['sportName']?.toString();

          if (price is int) {
            itemTotal += price;
          } else if (price is double) {
            itemTotal += price.toInt();
          }
        }

        tempList.add({
          'gym': data['gymId'],
          'date': dateString,
          'time': time ?? '',
          'amount': itemTotal,
          'sports': sportName ?? '',
        });

        count++;
        sum += itemTotal;
      }
    }

    setState(() {
      totalCount = count;
      totalAmount = sum;
      usageList = tempList;
    });
  }

  Future<void> selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        hasSelectedDate = true;
      });
      fetchUsageData();
    }
  }

  String formatCurrency(int amount) => NumberFormat.currency(locale: 'ko_KR', symbol: '').format(amount);

  @override
  Widget build(BuildContext context) {
    final dateRangeStr = '${DateFormat('yyyy-MM-dd').format(startDate)} ~ ${DateFormat('yyyy.MM.dd').format(endDate)}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomBackButton(),
              const SizedBox(height: 12),
              const Text(
                '이용내역',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('전체', style: TextStyle(fontSize: 15, color: Colors.black87)),
                  GestureDetector(
                    onTap: selectDateRange,
                    child: Row(
                      children: [
                        Text(dateRangeStr, style: const TextStyle(fontSize: 15, color: Colors.black)),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('총 $totalCount건', style: const TextStyle(color: Color(0xff69B7FF), fontSize: 14, fontWeight: FontWeight.w500)),
                  Text('사용 합계 ${formatCurrency(totalAmount)}원', style: const TextStyle(color: Color(0xff69B7FF), fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: !hasSelectedDate || usageList.isEmpty
                    ? const Center(child: Text('조회 결과가 없습니다.', style: TextStyle(color: Colors.grey, fontSize: 15)))
                    : ListView.separated(
                  itemCount: usageList.length,
                  separatorBuilder: (_, __) => const Divider(height: 20),
                  itemBuilder: (context, index) {
                    final item = usageList[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['gym'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('${item['date']} ${item['time']}  |  ${item['sports']}', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('${formatCurrency(item['amount'])}원', style: const TextStyle(color: Color(0xff69B7FF), fontWeight: FontWeight.w600, fontSize: 15)),
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
