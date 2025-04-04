class HomeEvent {
  final String name;
  final String location;
  final String imageUrl;
  final int price;
  final String date;
  final String time;

  HomeEvent({
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.date,
    required this.time,
  });

  // Firebase에서 가져온 Map 데이터를 객체로 변환하는 함수
  factory HomeEvent.fromMap(Map<String, dynamic> map, String id) {
    return HomeEvent(
      name: id, // 'name' 키로 받은 값이 없으면 빈 문자열을 기본값으로
      location: map['도로명'] ?? '', // '도로명' 키로 받은 값이 없으면 빈 문자열을 기본값으로
      imageUrl: map['imageUrl'] ?? 'assets/tennis.png', // 기본 이미지 URL 설정
      price: map['종목']['헬스장'] ?? 0, // '종목.헬스장' 가격, 없으면 0
      date: map['날짜'] ?? '날짜 없음', // '날짜' 값이 없으면 기본값
      time: map['운영시간'] ?? '시간 없음', // '운영시간' 값이 없으면 기본값
    );
  }

  // 객체를 Map 형태로 변환하는 함수 (필요시 사용)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'imageUrl': imageUrl,
      'price': price,
      'date': date,
      'time': time,
    };
  }
}


