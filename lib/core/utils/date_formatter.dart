// import 'package:intl/intl.dart';

// class DateFormatter {
//   static final DateFormat _monthDayYearFormat = DateFormat('MMM d, y');

//   /// Formats DateTime to "May 27, 2025" format
//   static String formatMonthDayYear(DateTime date) {
//     return _monthDayYearFormat.format(date);
//   }

//   /// Formats DateTime to "May 27, 2025, 10:30 AM" format
//   static String formatMonthDayYearWithTime(DateTime date) {
//     return '${_monthDayYearFormat.format(date)}, ${DateFormat.jm().format(date)}';
//   }

//   /// Formats DateTime to relative time (e.g., "2 hours ago")
//   static String formatRelativeTime(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inDays > 365) {
//       return '${(difference.inDays / 365).floor()} years ago';
//     } else if (difference.inDays > 30) {
//       return '${(difference.inDays / 30).floor()} months ago';
//     } else if (difference.inDays > 0) {
//       return '${difference.inDays} days ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours} hours ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes} minutes ago';
//     } else {
//       return 'Just now';
//     }
//   }
// }