import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

class QrcodePage extends StatefulWidget {
  const QrcodePage({Key? key}) : super(key: key);

  @override
  State<QrcodePage> createState() => _QrcodePageState();
}

class _QrcodePageState extends State<QrcodePage> {
  Map<String, dynamic>? currentReservation;
  bool isLoading = true;
  late Timer _timer;
  Duration remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    fetchReservation();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => updateRemainingTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchReservation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    try {
      final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final nickname = userSnapshot.data()?['nickname'] as String? ?? "";

      final reservationSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: today)
          .get();

      for (final doc in reservationSnapshot.docs) {
        final data = doc.data();
        final timeStr = data['time'] as String?;
        if (timeStr == null || timeStr.isEmpty) continue;

        final startTime = DateFormat('yyyy-MM-dd HH:mm').parse('$today $timeStr');
        final qrStartTime = startTime.subtract(const Duration(minutes: 5));
        final qrEndTime = startTime.add(const Duration(hours: 1));
        final now = DateTime.now();

        if (now.isAfter(qrStartTime) && now.isBefore(qrEndTime)) {
          setState(() {
            currentReservation = {
              ...data,
              'nickname': nickname,
            };
            isLoading = false;
          });
          updateRemainingTime();
          return;
        }
      }
    } catch (e) {
      print('Error fetching reservation: $e');
    }

    setState(() {
      currentReservation = null;
      isLoading = false;
    });
  }

  void updateRemainingTime() {
    if (currentReservation == null) return;

    final today = currentReservation!['date'] as String?;
    final time = currentReservation!['time'] as String?;
    if (today == null || time == null || today.isEmpty || time.isEmpty) return;

    final startTime = DateFormat('yyyy-MM-dd HH:mm').parse('$today $time');
    final endTime = startTime.add(const Duration(hours: 1));
    final now = DateTime.now();

    setState(() {
      remainingTime = endTime.difference(now);
      if (remainingTime.isNegative) {
        currentReservation = null;
      }
    });
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800, // ▶ 약한 bold
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600, // ▶ 기존보다 덜 bold
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (currentReservation == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('QR 체크인',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text('이용하려는 체육시설에 QR코드로 체크인하세요.',
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
                Spacer(),
                Center(
                  child: Text('예약된 시간에만 QR코드가 생성됩니다.',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    final String gym = currentReservation!['gymId'] as String? ?? '시설';
    final String name = currentReservation?['nickname']?.toString() ?? '';
    final String sport = currentReservation?['sports']?['sportName']?.toString() ?? '종목 없음';
    final String startDateStr = currentReservation!['date'] as String? ?? '';
    final String startTimeStr = currentReservation!['time'] as String? ?? '';
    final DateTime startTime = DateFormat('yyyy-MM-dd HH:mm').parse('$startDateStr $startTimeStr');
    final DateTime endTime = startTime.add(const Duration(hours: 1));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('QR 체크인',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('이용하려는 체육시설에 QR코드로 체크인하세요.',
                  style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // ✅ Card 몸통 하얀 배경
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300), // ✅ QR 코드 박스 보더
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFBFE1FF), // QR 박스 상단 파란 배경
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$gym 코드',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      QrImageView(
                        data: currentReservation.toString(),
                        size: 160,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            '남은 시간 ${formatDuration(remainingTime)}',
                            style: const TextStyle(fontSize: 14, color: Color(0xFF3977F3)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              detailItem('이름', name),
              detailItem('종목', sport),
              detailItem('시작시간',
                  DateFormat('yyyy-MM-dd (E) HH:mm', 'ko_KR').format(startTime)),
              detailItem('종료시간',
                  DateFormat('yyyy-MM-dd (E) HH:mm', 'ko_KR').format(endTime)),
            ],
          ),
        ),
      ),
    );
  }
}
