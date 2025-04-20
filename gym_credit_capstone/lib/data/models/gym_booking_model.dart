class GymBookingModel {
  final Map<String, String> sportsTranslation = {
    "축구장": "SCCR",
    "농구장": "BKB",
    "배드민턴장": "BMT",
    "테니스장": "TNS",
    "탁구장": "TBTNS",
    "야구장": "BSB",
    "풋살장": "FTS",
    "수영장": "PL",
    "골프장": "GLF"
  };

  String translateSportsSummary(String sportsSummary) {
    List<String> sportsList = sportsSummary.split(', ');
    List<String> translatedList = sportsList.map((sport) => sportsTranslation[sport.trim()] ?? sport).toList();
    return translatedList.join("_");
  }
}
