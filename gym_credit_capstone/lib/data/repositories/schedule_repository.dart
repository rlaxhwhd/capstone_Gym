import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Reservation>> fetchScheduleReservations(String userId) async {
    try {
      final snapshot = await _firestore.collection('reservations').get();

      print('[DEBUG SCHEDULE REPOSITORY] ${snapshot}');

      return snapshot.docs
          .where((doc) => doc.id.endsWith('_$userId'))
          .map((doc) => Reservation.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("Error fetching reservations: $e");
      return [];
    }
  }

  Future<void> cancelScheduleReservation(String docId) async {
    try {
      await _firestore.collection('reservations').doc(docId).update({'status': false});
      print('Reservation cancelled successfully.');
    } catch (e) {
      print('Error cancelling reservation: $e');
    }
  }
}