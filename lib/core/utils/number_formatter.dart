import 'package:intl/intl.dart';

class NumberFormatter {
  static String formatCount(int number) {
    if (number >= 1000000) {
      double res = number / 1000000;
      return '${res.toStringAsFixed(res.truncateToDouble() == res ? 0 : 1)}M';
    } else if (number >= 1000) {
      double res = number / 1000;
      return '${res.toStringAsFixed(res.truncateToDouble() == res ? 0 : 1)}K';
    } else {
      return NumberFormat('#,###').format(number);
    }
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
