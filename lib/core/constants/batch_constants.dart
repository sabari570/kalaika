/// Batch field options and storage values.
abstract final class BatchConstants {
  /// Preset dance styles in the create batch dropdown.
  static const List<String> presetDanceStyles = <String>[
    'Bharatanatyam',
    'Kuchipudi',
    'Mohiniyattam',
    'All',
  ];

  /// Batch covers every dance style offered.
  static const String danceStyleAll = 'All';

  /// Dropdown sentinel when the teacher enters a custom style.
  static const String danceStyleOther = 'Other';

  /// Stored batch mode values.
  static const String modeOffline = 'offline';
  static const String modeOnline = 'online';
  static const String modePrivate = 'private';

  /// All stored mode values in display order.
  static const List<String> modes = <String>[
    modeOffline,
    modeOnline,
    modePrivate,
  ];

  /// Weekday keys stored on the batch document.
  static const List<String> weekdayKeys = <String>[
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];
}
