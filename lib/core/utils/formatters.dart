import 'package:intl/intl.dart';

/// Formatters for displaying dates, times, and other values.
abstract class Formatters {
  // Date Formatters
  static final DateFormat _dateShort = DateFormat('MMM d, yyyy');
  static final DateFormat _dateLong = DateFormat('MMMM d, yyyy');
  static final DateFormat _dateNumeric = DateFormat('dd/MM/yyyy');
  static final DateFormat _time12h = DateFormat('h:mm a');
  static final DateFormat _time24h = DateFormat('HH:mm');
  static final DateFormat _dateTime = DateFormat('MMM d, yyyy at h:mm a');
  static final DateFormat _dateTimeShort = DateFormat('MMM d, h:mm a');
  static final DateFormat _iso8601 = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");

  /// Formats a date in short format (e.g., "Jan 1, 2024").
  static String formatDateShort(DateTime date) => _dateShort.format(date);

  /// Formats a date in long format (e.g., "January 1, 2024").
  static String formatDateLong(DateTime date) => _dateLong.format(date);

  /// Formats a date in numeric format (e.g., "01/01/2024").
  static String formatDateNumeric(DateTime date) => _dateNumeric.format(date);

  /// Formats a time in 12-hour format (e.g., "2:30 PM").
  static String formatTime12h(DateTime time) => _time12h.format(time);

  /// Formats a time in 24-hour format (e.g., "14:30").
  static String formatTime24h(DateTime time) => _time24h.format(time);

  /// Formats a date and time (e.g., "Jan 1, 2024 at 2:30 PM").
  static String formatDateTime(DateTime dateTime) => _dateTime.format(dateTime);

  /// Formats a date and time in short format (e.g., "Jan 1, 2:30 PM").
  static String formatDateTimeShort(DateTime dateTime) =>
      _dateTimeShort.format(dateTime);

  /// Formats a date to ISO 8601 format.
  static String formatIso8601(DateTime dateTime) =>
      _iso8601.format(dateTime.toUtc());

  /// Formats a relative time (e.g., "2 hours ago", "Just now").
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return formatDateShort(dateTime);
    }
  }

  /// Formats SpO2 percentage.
  static String formatSpo2(int value) => '$value%';

  /// Formats heart rate in BPM.
  static String formatBpm(int value) => '$value BPM';

  /// Formats a phone number.
  static String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 11 && cleaned.startsWith('0')) {
      // Egyptian format: 0XX XXXX XXXX
      return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 7)} ${cleaned.substring(7)}';
    } else if (cleaned.length == 10) {
      // US format: (XXX) XXX-XXXX
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    return phone;
  }

  /// Truncates text with ellipsis.
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Formats a name (capitalizes first letter of each word).
  static String formatName(String name) {
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Formats file size.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Formats confidence percentage for AI diagnosis.
  static String formatConfidence(double confidence) {
    return '${(confidence * 100).toStringAsFixed(1)}%';
  }
}
