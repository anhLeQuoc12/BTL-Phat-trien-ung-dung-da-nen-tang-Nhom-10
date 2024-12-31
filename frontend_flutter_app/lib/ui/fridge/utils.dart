import 'package:intl/intl.dart';

String formatDate(String dateString) {
  try {
    DateTime dateTime = DateTime.parse(dateString);

    String formattedDate = DateFormat('dd-MM-yy').format(dateTime);

    return formattedDate;
  } catch (e) {
    print('Error formatting date: $e');
    return '';
  }
}


