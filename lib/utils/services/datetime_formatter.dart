import 'package:intl/intl.dart';

class DatetimeFormatter {
  static final DateTime now = DateTime.now();

  String getTodayDisplayDate() {
    return DateFormat('d MMMM yyyy').format(now);
  }

  String getDisplayTimeNow() {
    return DateFormat('hh:mma').format(now);
  }

  DateTime getFormattedDateTime({format: String, String datetime}) {
    if (datetime == null || datetime == '') {
      return null;
    }
    DateTime convertedDateTime =
    DateFormat('yyyy-MM-dd HH:mm:ss').parse(datetime);
    return convertedDateTime;
  }

  String getFormattedDisplayDateTime(String datetime) {
    if (datetime == null || datetime == '') {
      return null;
    }
    DateTime convertedDateTime =
    DateFormat('yyyy-MM-dd HH:mm:ss').parse(datetime);
    return DateFormat('d MMMM yyyy hh:mma').format(convertedDateTime);
  }

  String getFormattedDisplayDate(String datetime) {
    if (datetime == null || datetime == '') {
      return null;
    }
    DateTime convertedDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse(datetime);
    return DateFormat('d MMMM yyyy').format(convertedDateTime);
  }

  String getFormattedDisplayTime(String datetime) {
    if (datetime == null || datetime == '') {
      return null;
    }
    DateTime convertedDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse(datetime);
    return DateFormat('hh:mma').format(convertedDateTime);
  }

  String getFormattedDateStr({String format, String datetime}) {
    if (datetime == null || datetime == '') {
      return null;
    }
    DateTime convertedDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse(datetime);
    return DateFormat(format).format(convertedDateTime);
  }

  String getFormattedDateStrWithDate({String format, DateTime datetime}) {
    if (datetime == null) {
      return null;
    }
    return DateFormat(format).format(datetime);
  }


  String getFormattedTimeStr({String format, String time}) {
    if (time == null || time == '') {
      return null;
    }

    DateTime convertedTime = DateFormat('HH:mm:ss').parse(time);
    return DateFormat(format).format(convertedTime);
  }

  int getDatetimeDifference({DateTime startDatetime, DateTime endDatetime}) {
    if (startDatetime == null || endDatetime == null) {
      return null;
    }
    return endDatetime.difference(startDatetime).inMinutes;
  }

  String getStrTimeOneHrFromTime({String time}) {
    if (time == null || time == '') {
      return '';
    }

    DateTime convertedTime = DateFormat('hh:mm a').parse(time);
    DateTime newTime = convertedTime.add(Duration(hours: 1));
    return DateFormat('hh:mm a').format(newTime);
  }

  String getStrTimeAfterMinute({String time, int interval}) {
    if (time == null || time == '' || interval == null) {
      return '';
    }

    DateTime convertedTime = DateFormat('hh:mm a').parse(time);
    DateTime newTime = convertedTime.add(Duration(minutes: interval));
    return DateFormat('hh:mm a').format(newTime);
  }

  String dateAmPm(String datetime) {
    return DateFormat('yyyy/MM/dd, hh:mm a').format(DateTime.parse(datetime));
  }

  static String dateAmPmWithoutDate(String datetime) {
    DateFormat inputFormat = DateFormat("HH:mm:ss");
    DateTime newDateTime = inputFormat.parse(datetime);
    return DateFormat('hh:mm a').format(newDateTime);
  }
}
