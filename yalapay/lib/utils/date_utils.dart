import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts Firestore date field (Timestamp/DateTime/String) to "yyyy-MM-dd"
String toYmdString(dynamic raw) {
  DateTime? dt;
  if (raw is Timestamp) {
    dt = raw.toDate();
  } else if (raw is DateTime) {
    dt = raw;
  } else if (raw is String) {
    dt = DateTime.tryParse(raw);
  }
  if (dt == null) return '';
  return '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';
}

/// Converts "yyyy-MM-dd" string to Firestore Timestamp (at midnight)
DateTime? ymdStringToDateTime(String s, {bool useNowOnFail = false}) {
  final dt = DateTime.tryParse(s);
  if (dt == null) return useNowOnFail ? DateTime.now() : null;
  return DateTime(dt.year, dt.month, dt.day); // midnight
}
