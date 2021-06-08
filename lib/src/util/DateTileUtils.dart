import 'package:intl/intl.dart' as DateTimeUtils;

class DateTileUtils {
  static DateTime stringToDateTime(String strDateTime) {
    DateTime tempDate =
        new DateTimeUtils.DateFormat("yyyy-MM-dd hh:mm:ss").parse(strDateTime);

    return tempDate;
  }

  static String dateTimeToFormattedString(DateTime dateTime) {
    String date = DateTimeUtils.DateFormat("yyyy-MM-dd").format(dateTime);

    return date;
  }

  static String getDDay(DateTime targetDate) {
    final today = DateTime.now();
    final difference = today.difference(targetDate).inDays;

    return difference.toString();
  }

  static String getDDayFromString(var targetDate) {
    if(targetDate == null) {
      return "";
    }

    else {
      final today = DateTime.now();
      DateTime targetDateTime = stringToDateTime(targetDate);
      final difference = today.difference(targetDateTime).inDays;

      return "D" + difference.toString();
    }

  }

  static String stringToDateTime2(String strDateTime) {
    DateTime tempDate = new DateTimeUtils.DateFormat("yyyy-MM-dd").parse(strDateTime);

    return DateTimeUtils.DateFormat("yyyy-MM-dd hh:mm:ss").format(tempDate);
  }

  static String getToday() {
    final today = DateTime.now();

    return DateTimeUtils.DateFormat("yyyy-MM-dd hh:mm:ss").format(today);
  }

}
