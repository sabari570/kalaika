/// User-visible copy for the Kalaika application.
abstract final class AppStrings {
  /// Application title shown in the task switcher.
  static const String appTitle = 'Kalaika';

  /// Subtitle on the splash screen.
  static const String feeManagement = 'Fee Management';

  /// Institute tagline default and logo fallback.
  static const String taglineByLakshmi = 'By Lakshmi Kumaran';

  /// Bottom navigation labels.
  static const String navDashboard = 'Dashboard';
  static const String navBranches = 'Branches';
  static const String navSettings = 'Settings';

  /// Placeholder screen titles (M1).
  static const String dashboardPlaceholder =
      'Dashboard content will appear here.';
  static const String branchesPlaceholder =
      'Branch management will appear here.';
  static const String settingsPlaceholder = 'Settings will appear here.';

  /// Style guide screen.
  static const String styleGuideTitle = 'Design system';
  static const String openStyleGuide = 'Open design system gallery';

  /// Shared actions.
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String retry = 'Retry';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String createBranch = 'Create branch';
  static const String newBranch = 'New branch';
  static const String editBranch = 'Edit branch';
  static const String branchName = 'Branch name';
  static const String branchLocation = 'Location or address';
  static const String branchContact = 'Contact number';
  static const String branchNameRequired = 'Branch name is required.';
  static const String branchNotFound = 'The branch could not be found.';
  static const String cannotDeleteBranchWithBatches =
      'This branch cannot be deleted while it contains batches.';
  static const String deleteBranchConfirm =
      'This branch will be removed permanently.';
  static const String batchesLabel = 'Batches';
  static const String studentsLabel = 'Students';
  static const String newBatch = 'New batch';
  static const String editBatch = 'Edit batch';
  static const String batchName = 'Batch name';
  static const String danceStyle = 'Dance style';
  static const String classMode = 'Class mode';
  static const String classDays = 'Class days';
  static const String classTime = 'Class time';
  static const String monthlyFee = 'Monthly fee per student';
  static const String batchFeeHelper =
      'This amount is used by default when recording each '
      "student's monthly payment.";
  static const String batchNameRequired = 'Batch name is required.';
  static const String batchFeeInvalid =
      'Monthly fee must be a positive whole number.';
  static const String batchNotFound = 'The batch could not be found.';
  static const String cannotDeleteBatchWithStudents =
      'This batch cannot be deleted while it contains students. '
      'You may deactivate it instead.';
  static const String deactivateBatch = 'Deactivate batch';
  static const String deactivateBatchConfirm =
      'The batch will be hidden from the fee tracker. Existing '
      'student records are retained.';
  static const String deleteBatchConfirm =
      'This batch will be removed permanently.';
  static const String batchFeeChangeTitle = 'Update batch fee';
  static const String batchFeeChangeMessage =
      'Choose how the updated fee should apply to students in '
      'this batch.';
  static const String applyFeeNewStudentsOnly = 'Apply to new students only';
  static const String applyFeeAllStudents = 'Apply to all active students';
  static const String batchDetailPlaceholder =
      'Fee tracking and student management will be available in '
      'the next milestone.';
  static const String continueWithGoogle = 'Continue with Google';
  static const String signInTitle = 'Sign in';
  static const String signInSubtitle =
      'Use your Google account to access Kalaika.';
  static const String signOut = 'Sign out';
  static const String signOutConfirmTitle = 'Sign out';
  static const String signOutConfirmMessage =
      'You will need to sign in again to access Kalaika.';
  static const String signInFailed =
      'Sign in could not be completed. Please try again.';
  static const String firebaseInitFailed =
      'The application could not be initialized. Please restart the app.';

  /// Empty states.
  static const String noBranchesYet = 'No branches have been created.';
  static const String noBatchesYet = 'No batches have been created.';

  /// Status chip labels.
  static const String statusUnpaid = 'Unpaid';
  static const String statusPendingSend = 'Pending send';
  static const String statusSent = 'Sent';

  /// Generic errors.
  static const String unknownError =
      'An unexpected error occurred. Please try again.';
  static const String networkError =
      'A network connection is required. Please try again.';
  static const String receiptGenerateFailed =
      'The receipt could not be generated. Please try again.';

  /// Month selector accessibility.
  static const String previousMonth = 'Previous month';
  static const String nextMonth = 'Next month';
  static const String selectMonth = 'Select month and year';

  /// Style guide section labels.
  static const String sectionButtons = 'Buttons';
  static const String sectionCards = 'Cards';
  static const String sectionInputs = 'Inputs';
  static const String sectionStatus = 'Status';
  static const String sectionTypography = 'Typography';
  static const String sectionMonthSelector = 'Month selector';
  static const String sectionFeedback = 'Feedback';
  static const String sampleStatLabel = 'Collected';
  static const String sampleStatValue = '12,500';
  static const String sampleEmptyMessage = 'No items to display.';
  static const String sampleSectionTitle = 'Section title';
  static const String sampleFieldLabel = 'Branch name';
  static const String sampleFieldHint = 'Enter branch name';
}
