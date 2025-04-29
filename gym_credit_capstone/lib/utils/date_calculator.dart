class DateCalculator {
  String getDayOfWeek(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      List<String> koreanDays = ['일', '월', '화', '수', '목', '금', '토'];
      return koreanDays[parsedDate.weekday % 7];
    } catch (e) {
      print('날짜 변환 오류: $e');
      return '';
    }
  }
}