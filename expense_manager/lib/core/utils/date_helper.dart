import 'package:intl/intl.dart';

class DateHelper {
  // Format date as "dd MMM yyyy" (e.g., "14 Jan 2026")
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Format date as "dd/MM/yyyy"
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Format date and time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  // Get today's date range (start and end of day)
  static DateRange getToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return DateRange(start: startOfDay, end: endOfDay);
  }

  // Get this week's date range (Monday to Sunday)
  static DateRange getThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return DateRange(
      start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day, 0, 0, 0),
      end: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59),
    );
  }

  // Get this month's date range
  static DateRange getThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1, 0, 0, 0);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return DateRange(start: startOfMonth, end: endOfMonth);
  }

  // Get current month name
  static String getCurrentMonthName() {
    return DateFormat('MMMM yyyy').format(DateTime.now());
  }

  // Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Get start and end of a specific date
  static DateRange getDateRange(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return DateRange(start: startOfDay, end: endOfDay);
  }
}

// Date range model
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});
}