import 'package:intl/intl.dart';

class DateHelper {
  String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
