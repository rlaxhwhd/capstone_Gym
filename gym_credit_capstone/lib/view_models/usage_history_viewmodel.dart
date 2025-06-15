import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/reservation_model.dart';

class UsageHistoryViewModel extends ChangeNotifier {
  List<Reservation> _usageList = [];
  List<Reservation> get usageList => _usageList;

  int get totalCount => _usageList.length;
  int get totalAmount => _usageList.fold(0, (sum, r) => sum + r.amount);

  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  String selectedPeriod = '1개월';
  String selectedCategory = '전체';
  String selectedPayment = '전체';

  Future<void> fetchUsageData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('userId', isEqualTo: userId)
          .get();

      final List<Reservation> tempList = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final dateString = data['date'] as String?;
        if (dateString == null) continue;

        final date = DateTime.tryParse(dateString);
        if (date == null) continue;

        if (date.isBefore(startDate) || date.isAfter(endDate)) continue;

        final sportsName = data['sports']?['sportName'] ?? '기타';
        if (selectedCategory != '전체' && selectedCategory != sportsName) continue;

        tempList.add(Reservation.fromMap(data));
      }

      _usageList = tempList;
      notifyListeners();
    } catch (e) {
      debugPrint('fetchUsageData error: $e');
    }
  }

  void setFilter({
    required String period,
    required String category,
    required String payment,
    required DateTime start,
    required DateTime end,
  }) {
    selectedPeriod = period;
    selectedCategory = category;
    selectedPayment = payment;
    startDate = start;
    endDate = end;
    notifyListeners();
  }

  void updatePeriod(String period) {
    selectedPeriod = period;
    _setDefaultDatesFromPeriod();
    notifyListeners();
  }

  void updateCategory(String categoryCode) {
    selectedCategory = categoryCode;
    notifyListeners();
  }

  void updatePayment(String payment) {
    selectedPayment = payment;
    notifyListeners();
  }

  void updateDateRange(DateTime start, DateTime end) {
    startDate = start;
    endDate = end;
    notifyListeners();
  }

  void _setDefaultDatesFromPeriod() {
    final now = DateTime.now();
    if (selectedPeriod == '1개월') {
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0);
    } else if (selectedPeriod == '1년') {
      startDate = DateTime(now.year, 1, 1);
      endDate = DateTime(now.year, 12, 31);
    } else {
      startDate = DateTime(now.year, now.month, 1);
      endDate = startDate.add(const Duration(days: 30));
    }
  }
}
