/// Age helpers for student records.
abstract final class AgeUtils {
  /// Computes whole years from [dateOfBirth] to [reference] (defaults to now).
  static int? ageFromDateOfBirth(
    DateTime dateOfBirth, {
    DateTime? reference,
  }) {
    final today = reference ?? DateTime.now();
    var age = today.year - dateOfBirth.year;
    final birthdayThisYear = DateTime(
      today.year,
      dateOfBirth.month,
      dateOfBirth.day,
    );
    if (today.isBefore(birthdayThisYear)) {
      age--;
    }
    if (age < 0) {
      return null;
    }
    return age;
  }

  /// Returns true when [age] is acceptable for manual entry.
  static bool isValidManualAge(int age) {
    return age >= 1 && age <= 100;
  }
}
