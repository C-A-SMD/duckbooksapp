import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirestoreDateUtils {
  static final DateFormat _legacyFormat = DateFormat('dd/MM/yyyy HH:mm');

  static DateTime? parse(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is String) {
      final text = value.trim();
      if (text.isEmpty || text == 'null') {
        return null;
      }

      try {
        return _legacyFormat.parse(text);
      } catch (_) {
        return DateTime.tryParse(text);
      }
    }

    return null;
  }

  static Timestamp? toTimestamp(dynamic value) {
    final dt = parse(value);
    if (dt == null) {
      return null;
    }
    return Timestamp.fromDate(dt);
  }

  static String? toLegacyString(dynamic value) {
    final dt = parse(value);
    if (dt == null) {
      return null;
    }
    return _legacyFormat.format(dt);
  }

  static String displayDate(dynamic value,
      {String pattern = 'dd/MM/yyyy HH:mm'}) {
    final dt = parse(value);
    if (dt == null) {
      return '--';
    }
    return DateFormat(pattern).format(dt);
  }
}
