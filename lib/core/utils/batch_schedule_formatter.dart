import 'package:feemanager/core/constants/batch_constants.dart';

/// Formats batch schedule fields for list cards.
abstract final class BatchScheduleFormatter {
  /// Builds a readable schedule line from [days] and [classTime].
  static String format({
    required List<String> days,
    required String classTime,
  }) {
    final labels = days
        .map(_weekdayLabel)
        .where((label) => label.isNotEmpty)
        .toList();
    final daysText = labels.isEmpty ? '' : labels.join(', ');
    if (daysText.isEmpty) {
      return classTime.trim();
    }
    if (classTime.trim().isEmpty) {
      return daysText;
    }
    return '$daysText · ${classTime.trim()}';
  }

  static String _weekdayLabel(String key) {
    final index = BatchConstants.weekdayKeys.indexOf(key);
    if (index < 0) {
      return '';
    }
    const names = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return names[index];
  }

  /// User-facing label for a stored [mode] value.
  static String modeLabel(String mode) {
    return switch (mode) {
      BatchConstants.modeOffline => 'Offline',
      BatchConstants.modeOnline => 'Online',
      BatchConstants.modePrivate => 'Private',
      _ => mode,
    };
  }
}
