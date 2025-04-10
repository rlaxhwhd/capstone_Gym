import 'package:latlong2/latlong.dart';

class DistanceCalculator {
  static final Distance _distance = Distance();

  static double calculateKm({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    final start = LatLng(startLat, startLng);
    final end = LatLng(endLat, endLng);

    return _distance.as(LengthUnit.Kilometer, start, end);
  }
}