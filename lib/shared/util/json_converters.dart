import 'package:json_annotation/json_annotation.dart';

/// Converts a date-only string (e.g. `"2025-06-01"`) to [DateTime] (UTC midnight)
/// and back. Also handles full ISO-8601 strings gracefully.
class DateConverter implements JsonConverter<DateTime, String> {
  const DateConverter();

  static final _dateOnlyPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  @override
  DateTime fromJson(String json) {
    if (json.length == 10 && _dateOnlyPattern.hasMatch(json)) {
      return DateTime.parse('${json}T00:00:00Z');
    }
    return DateTime.parse(json);
  }

  @override
  String toJson(DateTime json) => json.toIso8601String().split('T')[0];
}
