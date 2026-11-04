/// Central route path constants for go_router.
abstract final class AppRoutes {
  /// Splash screen.
  static const String splash = '/splash';

  /// Google sign-in screen.
  static const String login = '/login';

  /// Home shell redirect target.
  static const String home = '/home';

  /// Dashboard tab.
  static const String dashboard = '/home/dashboard';

  /// Branches tab.
  static const String branches = '/home/branches';

  /// Settings tab.
  static const String settings = '/home/settings';

  /// Edit institute details.
  static const String settingsInstitute = '/home/settings/institute';

  /// Edit WhatsApp message template.
  static const String settingsTemplate = '/home/settings/template';

  /// Pending receipts review from the dashboard.
  static const String dashboardPending = '/home/dashboard/pending-receipts';

  /// Debug-only design system gallery.
  static const String styleGuide = '/debug/style-guide';

  /// Create branch form.
  static const String branchNew = '/branches/new';

  /// Branch detail and batch list.
  static const String branchDetail = '/branches/:branchId';

  /// Edit branch form.
  static const String branchEdit = '/branches/:branchId/edit';

  /// Create batch form.
  static const String batchNew = '/branches/:branchId/batches/new';

  /// Batch fee tracker and students.
  static const String batchDetail = '/branches/:branchId/batches/:batchId';

  /// Edit batch form.
  static const String batchEdit = '/branches/:branchId/batches/:batchId/edit';

  /// Add student form.
  static const String studentNew =
      '/branches/:branchId/batches/:batchId/students/new';

  /// Student detail.
  static const String studentDetail =
      '/branches/:branchId/batches/:batchId/students/:studentId';

  /// Edit student form.
  static const String studentEdit =
      '/branches/:branchId/batches/:batchId/students/:studentId/edit';

  /// Excel import flow.
  static const String importStudents =
      '/branches/:branchId/batches/:batchId/import';

  /// Builds a branch detail path for [branchId].
  static String branchDetailPath(String branchId) => '/branches/$branchId';

  /// Builds a branch edit path for [branchId].
  static String branchEditPath(String branchId) => '/branches/$branchId/edit';

  /// Builds a new batch path under [branchId].
  static String batchNewPath(String branchId) =>
      '/branches/$branchId/batches/new';

  /// Builds a batch detail path.
  static String batchDetailPath(String branchId, String batchId) =>
      '/branches/$branchId/batches/$batchId';

  /// Builds a batch edit path.
  static String batchEditPath(String branchId, String batchId) =>
      '/branches/$branchId/batches/$batchId/edit';

  /// Builds a new student path.
  static String studentNewPath(String branchId, String batchId) =>
      '/branches/$branchId/batches/$batchId/students/new';

  /// Builds a student detail path.
  static String studentDetailPath(
    String branchId,
    String batchId,
    String studentId,
  ) =>
      '/branches/$branchId/batches/$batchId/students/$studentId';

  /// Builds a student edit path.
  static String studentEditPath(
    String branchId,
    String batchId,
    String studentId,
  ) =>
      '/branches/$branchId/batches/$batchId/students/$studentId/edit';

  /// Builds the Excel import path.
  static String importStudentsPath(String branchId, String batchId) =>
      '/branches/$branchId/batches/$batchId/import';
}
