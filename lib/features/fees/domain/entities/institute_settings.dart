import 'package:equatable/equatable.dart';

/// Institute block on the user profile used for receipts.
class InstituteSettings extends Equatable {
  /// Creates institute settings.
  const InstituteSettings({
    required this.name,
    required this.tagline,
    required this.addressLines,
    required this.phone,
    required this.footerNote,
    required this.signatory,
  });

  /// Institute display name.
  final String name;

  /// Tagline under the name.
  final String tagline;

  /// Address lines.
  final List<String> addressLines;

  /// Contact phone.
  final String phone;

  /// Footer note on receipts.
  final String footerNote;

  /// Signatory line.
  final String signatory;

  /// Returns a copy with the given fields replaced.
  InstituteSettings copyWith({
    String? name,
    String? tagline,
    List<String>? addressLines,
    String? phone,
    String? footerNote,
    String? signatory,
  }) {
    return InstituteSettings(
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      addressLines: addressLines ?? this.addressLines,
      phone: phone ?? this.phone,
      footerNote: footerNote ?? this.footerNote,
      signatory: signatory ?? this.signatory,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    name,
    tagline,
    addressLines,
    phone,
    footerNote,
    signatory,
  ];
}
