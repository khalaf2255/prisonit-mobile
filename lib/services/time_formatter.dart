class TimeFormatter {
  static String formatArabicTimeSpan(Duration duration) {
    int totalSeconds = duration.inSeconds;
    if (totalSeconds <= 0) return "0 ثانية";

    int days = totalSeconds ~/ 86400;
    int remSec = totalSeconds % 86400;
    int hours = remSec ~/ 3600;
    remSec %= 3600;
    int minutes = remSec ~/ 60;
    int seconds = remSec % 60;

    List<String> parts = [];

    if (days > 0) {
      parts.add("$days ${days == 1 ? "يوم" : (days == 2 ? "يومان" : (days <= 10 ? "أيام" : "يوم"))}");
    }
    if (hours > 0) {
      parts.add("$hours ${hours == 1 ? "ساعة" : (hours == 2 ? "ساعتان" : (hours <= 10 ? "ساعات" : "ساعة"))}");
    }
    if (minutes > 0) {
      parts.add("$minutes ${minutes == 1 ? "دقيقة" : (minutes == 2 ? "دقيقتان" : (minutes <= 10 ? "دقائق" : "دقيقة"))}");
    }
    if (seconds > 0 || parts.isEmpty) {
      parts.add("$seconds ${seconds == 1 ? "ثانية" : (seconds == 2 ? "ثانيتان" : (seconds <= 10 ? "ثوانٍ" : "ثانية"))}");
    }

    return parts.join(" و ");
  }

  static String formatArabicTimeSpanFromSeconds(int seconds) {
    return formatArabicTimeSpan(Duration(seconds: seconds));
  }
}
