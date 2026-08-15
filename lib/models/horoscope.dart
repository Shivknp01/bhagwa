class Horoscope {
  final String sign;
  final String? signHi;
  final String symbol;
  final String date;
  final String overview;
  final String? overviewHi;
  final String luckyNumber;
  final String luckyColor;
  final String luckyTime;
  final String advice;
  final String? adviceHi;

  const Horoscope({
    required this.sign,
    this.signHi,
    required this.symbol,
    required this.date,
    required this.overview,
    this.overviewHi,
    required this.luckyNumber,
    required this.luckyColor,
    required this.luckyTime,
    required this.advice,
    this.adviceHi,
  });

  String localizedSign(String lang) {
    if (lang == 'hi' && signHi != null && signHi!.isNotEmpty) {
      return signHi!;
    }
    return sign;
  }

  String localizedOverview(String lang) {
    if (lang == 'hi' && overviewHi != null && overviewHi!.isNotEmpty) {
      return overviewHi!;
    }
    return overview;
  }

  String localizedAdvice(String lang) {
    if (lang == 'hi' && adviceHi != null && adviceHi!.isNotEmpty) {
      return adviceHi!;
    }
    return advice;
  }
}
