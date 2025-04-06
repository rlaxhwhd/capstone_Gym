import 'package:cloud_firestore/cloud_firestore.dart';

class GymInfo {
  final String name; // 체육관 이름(문서명)
  final String location; // 도로명
  final String imageUrl; // 이미지 URL
  final String facilityHours; // 시설 운영 시간
  final String tel; // 전화 번호
  final GeoPoint coord; // 위치 좌표
  final bool isPaid; // 유료 여부
  final bool isMembership; // 회원제 여부
  final Map<String, int> sports; // 종목별 가격 (추가)
  final Map<String,bool> gymFacility; // 부대시설

  GymInfo({
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.facilityHours,
    required this.tel,
    required this.coord,
    required this.isPaid,
    required this.isMembership,
    required this.sports,
    required this.gymFacility,
  });

  // Firebase에서 가져온 Map 데이터를 객체로 변환하는 함수
  factory GymInfo.fromMap(Map<String, dynamic> map, String id) {
    return GymInfo(
      name: id,
      location: map['도로명'] ?? '',
      imageUrl: 'assets/images/gyms/$id.png',
      facilityHours: map['운영시간'] ?? '정보 없음',
      tel: map['전화번호'] ?? '정보 없음',
      coord: map['위치'] != null ? map['위치'] as GeoPoint : GeoPoint(0, 0), // 좌표 변환
      isPaid: map['유료'] ?? false,
      isMembership: map['회원제'] ?? false,
      sports: (map['종목'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, int.tryParse(value.toString()) ?? 0)) ?? {},
      gymFacility: (map['부대시설'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, value as bool)) ?? {},
    );
  }

  // 객체를 Map 형태로 변환하는 함수
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'imageUrl': imageUrl,
      'facilityHours': facilityHours,
      'tel': tel,
      'coord': coord, // GeoPoint 그대로 저장
      'isPaid': isPaid,
      'isMembership': isMembership,
      'sports': sports, // 종목 저장
      'gymFacility': gymFacility, // 부대시설 추가
    };
  }
}
