import 'package:intl/intl.dart';

extension StudyonDateUtils on DateTime {
  String toDateString() => DateFormat('yyyy-MM-dd').format(this);

  String toTimeString() => DateFormat('HH:mm').format(this);

  String toDateTimeString() => DateFormat('yyyy-MM-dd HH:mm').format(this);

  String toIso8601KST() => toIso8601String();

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get startOfWeek {
    final weekday = this.weekday;
    return subtract(Duration(days: weekday - 1)).startOfDay;
  }
}
