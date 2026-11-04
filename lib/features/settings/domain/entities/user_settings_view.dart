import 'package:equatable/equatable.dart';
import 'package:feemanager/features/auth/domain/entities/app_user.dart';
import 'package:feemanager/features/fees/domain/entities/institute_settings.dart';

/// Read-only settings summary for the Settings tab.
class UserSettingsView extends Equatable {
  /// Creates a settings view model.
  const UserSettingsView({
    required this.user,
    required this.institute,
    required this.messageTemplate,
  });

  /// Signed-in account.
  final AppUser user;

  /// Institute block used on receipts.
  final InstituteSettings institute;

  /// WhatsApp message template body.
  final String messageTemplate;

  /// First three non-empty lines of [messageTemplate] for preview.
  List<String> get templatePreviewLines {
    final lines = messageTemplate
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .take(3)
        .toList();
    return lines;
  }

  @override
  List<Object?> get props => <Object?>[user, institute, messageTemplate];
}
