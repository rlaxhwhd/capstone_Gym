import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MapTab extends StatelessWidget {
  final double latitude;
  final double longitude;

  const MapTab({super.key, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 28),
      height: 300,
      width: double.infinity,
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(latitude, longitude),
            zoom: 15,
          ),
        ),
        onMapReady: (controller) async {
          final marker = NMarker(
            id: 'gym_marker',
            position: NLatLng(latitude, longitude),
          );
          await controller.addOverlay(marker);
        },
      ),
    );
  }

}