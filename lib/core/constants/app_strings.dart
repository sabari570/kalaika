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
  static const String continueWithGoogle = 'Continue with Google';

  /// Empty states.
  static const String noBranchesYet = 'No branches have been created.';

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
