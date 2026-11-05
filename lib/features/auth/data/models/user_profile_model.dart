import 'package:feemanager/core/constants/app_defaults.dart';
import 'package:feemanager/core/constants/firestore_keys.dart';

/// Firestore shape for `users/{uid}` defaults.
abstract final class UserProfileModel {
  /// Builds the initial user document for a new account.
  static Map<String, Object?> newUserDocument({
    required String displayName,
    required String email,
  }) {
    return <String, Object?>{
      FirestoreKeys.displayName: displayName,
      FirestoreKeys.email: email,
      FirestoreKeys.institute: <String, Object?>{
        FirestoreKeys.name: AppDefaults.instituteName,
        FirestoreKeys.tagline: AppDefaults.instituteTagline,
        FirestoreKeys.addressLines: <String>[],
        FirestoreKeys.phone: AppDefaults.institutePhone,
        FirestoreKeys.footerNote: '',
        FirestoreKeys.signatory: '',
      },
      FirestoreKeys.messageTemplate: AppDefaults.messageTemplate,
      FirestoreKeys.whatsappDeliveryMode:
          AppDefaults.whatsappDeliveryModeValue,
    };
  }
}
