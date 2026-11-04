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

  /// Dashboard.
  static const String dashboardWelcome = 'Welcome, {name}';
  static const String dashboardStatCollected = 'Collected';
  static const String dashboardStatPending = 'Pending amount';
  static const String dashboardStatReceiptsSent = 'Receipts sent';
  static const String dashboardStatActiveStudents = 'Active students';
  static const String dashboardStatSentOverPaid = '{sent} of {paid}';
  static const String dashboardCollectionProgress = 'Collection progress';
  static const String dashboardReceiptsPendingTitle = 'Receipts pending';
  static const String dashboardReceiptsPendingCount =
      '{count} receipts await delivery';
  static const String dashboardReviewPending = 'Review';
  static const String dashboardBranchesSection = 'Branches';
  static const String dashboardBranchBatches = '{count} batches';
  static const String dashboardBatchPaidOfTotal = 'Paid {paid} of {total}';
  static const String dashboardNoBranches =
      'No branches have been created.';
  static const String dashboardLoadFailed =
      'The dashboard could not be loaded. Please try again.';
  static const String pendingReceiptsTitle = 'Receipts pending';
  static const String pendingReceiptsEmpty =
      'All recorded receipts have been sent.';
  static const String pendingReceiptsLoadFailed =
      'Pending receipts could not be loaded. Please try again.';

  /// Placeholder screen titles (M1).
  static const String branchesPlaceholder =
      'Branch management will appear here.';
  static const String settingsScreenTitle = 'Settings';
  static const String settingsAccount = 'Account';
  static const String settingsGoogleAccount = 'Google account';
  static const String settingsInstitute = 'Institute details';
  static const String settingsInstituteName = 'Institute name';
  static const String settingsInstituteTagline = 'Tagline';
  static const String settingsInstitutePhone = 'Contact phone';
  static const String settingsInstituteSignatory = 'Signatory';
  static const String settingsInstituteAddress = 'Address';
  static const String settingsInstituteFooter = 'Receipt footer note';
  static const String settingsEditInstitute = 'Edit institute details';
  static const String settingsEditTemplate = 'Edit message template';
  static const String settingsMessageTemplate = 'Receipts and messaging';
  static const String settingsTemplatePreview = 'Message template preview';
  static const String settingsTemplateEditor = 'Message template';
  static const String settingsTemplatePlaceholders =
      'Placeholders: {recipient_name}, {student_name}, {amount}, '
      '{batch_fee}, {month}, {year}, {batch_name}, {branch_name}, '
      '{receipt_no}, {receipt_url}, {institute_name}';
  static const String settingsResetTemplate = 'Reset to default';
  static const String settingsInstituteSaved =
      'Institute details have been saved.';
  static const String settingsTemplateSaved =
      'The message template has been saved.';
  static const String settingsSaveFailed =
      'Your changes could not be saved. Please try again.';
  static const String settingsInstituteNameRequired =
      'Institute name is required.';
  static const String settingsSignOutSection = 'Session';
  static const String settingsLoadFailed =
      'Settings could not be loaded. Please try again.';
  static const String appVersionLabel = 'Version';
  static const String signInPrivacyNote =
      'Your Google account is used only to sign in securely.';

  /// Style guide screen.
  static const String styleGuideTitle = 'Design system';
  static const String openStyleGuide = 'Open design system gallery';

  /// Shared actions.
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String yes = 'Yes';
  static const String no = 'No';
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
  static const String deactivateBatch = 'Deactivate batch';
  static const String deactivateBatchConfirm =
      'The batch will be hidden from the fee tracker. Existing '
      'student records are retained.';
  static const String deleteBatchConfirm =
      'This batch will be removed permanently.';
  static const String deleteBatchWithStudentsConfirm =
      'This batch has registered students. Deleting it will permanently '
      'remove the batch, all student records, and all fee payments '
      'associated with them. Are you sure you wish to proceed?';
  static const String deleteStudentTitle = 'Delete student';
  static const String deleteStudentConfirm =
      'This student and their payment history will be removed permanently.';
  static const String studentDeletedSuccess =
      'The student has been removed successfully.';
  static const String batchDeletedSuccess =
      'The batch has been removed successfully.';
  static const String branchDeletedSuccess =
      'The branch has been removed successfully.';
  static const String batchFeeChangeTitle = 'Update batch fee';
  static const String batchFeeChangeMessage =
      'Choose how the updated fee should apply to students in '
      'this batch.';
  static const String applyFeeNewStudentsOnly = 'Apply to new students only';
  static const String applyFeeAllStudents = 'Apply to all active students';
  static const String batchDetailPlaceholder =
      'The fee tracker for this batch will be available in the '
      'next milestone.';
  static const String tabFees = 'Fees';
  static const String tabStudents = 'Students';
  static const String feeSearchHint =
      'Search by student or guardian name';
  static const String feeFilterAll = 'All';
  static const String feePaidOfTotal = 'Paid {paid} of {total}';
  static const String feeCollected = 'Collected Rs. {amount}';
  static const String noMatchingFeeRows =
      'No students match the current filter.';
  static const String sendReceipt = 'Send';
  static const String recordPayment = 'Record payment';
  static const String recordPaymentConfirmIntro =
      'You are about to mark the following class fee as paid.';
  static const String recordPaymentAmountLine = 'Amount: Rs. {amount}';
  static const String recordPaymentAmountLabel = 'Amount';
  static const String recordPaymentMonthLine = 'Month: {month}';
  static const String recordPaymentBatchFeeLine = 'Batch fee: Rs. {amount}';
  static const String paymentNoteOptional = 'Note (optional)';
  static const String paymentModeCash = 'Cash';
  static const String paymentModeUpi = 'UPI';
  static const String paymentModeBank = 'Bank transfer';
  static const String paymentModeOther = 'Other';
  static const String recordPaymentIrreversible =
      'This action is irreversible. A payment record and PDF receipt '
      'will be created for this month.';
  static const String confirmAndGenerateReceipt =
      'Confirm and generate receipt';
  static const String generatingReceipt = 'Generating receipt';
  static const String preparingReceiptShare = 'Preparing receipt to share';
  static const String deleting = 'Deleting';
  static const String paymentMode = 'Payment mode';
  static const String paidOnDate = 'Paid on';
  static const String markReceiptSentTitle = 'Receipt delivery';
  static const String markReceiptSentMessage =
      'Was the receipt and message sent to {name}?';
  static const String receiptAttachedWithMessage =
      'Attached with this message';
  static const String validWhatsappRequired =
      'A valid WhatsApp number is required.';
  static const String receiptDetails = 'Receipt details';
  static const String resendOnWhatsapp = 'Resend on WhatsApp';
  static const String markReceiptSentYes = 'Yes, mark as sent';
  static const String markReceiptSentNo = 'Not yet';
  static const String voidPayment = 'Mark as unpaid (void receipt)';
  static const String voidPaymentConfirm =
      'This payment will be voided and the fee row will return to unpaid.';
  static const String feeReceiptShareSubject = 'Fee receipt';
  static const String confirmPayment = 'Confirm payment';
  static const String statusSentOn = 'Sent on {date}';
  static const String addStudent = 'Add student';
  static const String importFromExcel = 'Import from Excel';
  static const String editStudent = 'Edit student';
  static const String newStudent = 'New student';
  static const String studentName = 'Full name';
  static const String phoneNumber = 'Phone number';
  static const String whatsappNumber = 'WhatsApp number';
  static const String sameAsPhone = 'Same as phone number';
  static const String dateOfBirth = 'Date of birth';
  static const String age = 'Age';
  static const String guardian = 'Guardian';
  static const String guardianPhone = 'Guardian phone number';
  static const String address = 'Address';
  static const String studentNameRequired = 'Full name is required.';
  static const String whatsappRequired = 'WhatsApp number is required.';
  static const String studentFeeInvalid =
      'Monthly fee must be a positive whole number.';
  static const String studentNotFound = 'The student could not be found.';
  static const String studentDuplicate =
      'Another student in this batch already uses the same full name '
      'and WhatsApp number.';
  static const String phoneInvalid = 'The phone number is not valid.';
  static const String phoneNeedsCorrection =
      'The phone number must be corrected before import.';
  static const String phoneConfirmTitle = 'Confirm phone number';
  static const String phoneConfirmMessage =
      'Please confirm that this international number is correct.';
  static const String noStudentsYet = 'No students have been added.';
  static const String activeStudent = 'Active';
  static const String call = 'Call';
  static const String paymentHistory = 'Payment history';
  static const String noPaymentHistory = 'No payments have been recorded.';
  static const String openReceipt = 'Open receipt';
  static const String receiptOpenFailed =
      'The receipt could not be opened. Please try again.';
  static const String importStudentsTitle = 'Import students';
  static const String pickExcelFile = 'Choose Excel file';
  static const String downloadSampleTemplate = 'Download sample template';
  static const String importConfirm = 'Import valid rows';
  static const String importParsing = 'Reading the file…';
  static const String importInProgress = 'Importing students…';
  static const String importCompleteTitle = 'Import complete';
  static const String importXlsNotSupported =
      'Please save the file as .xlsx and try again.';
  static const String importNameRequired = 'Full name is required.';
  static const String importWhatsappRequired =
      'WhatsApp number is required.';
  static const String importWhatsappFromPhone =
      'WhatsApp number was taken from the phone number.';
  static const String importDobInvalid =
      'Date of birth could not be understood.';
  static const String importAgeInvalid =
      'Age must be a whole number from 1 to 100.';
  static const String importGuardianPhoneDropped =
      'Guardian phone number was invalid and has been omitted.';
  static const String importDuplicateInFile =
      'This row duplicates another row in the file.';
  static const String importDuplicateExisting =
      'A student with this name and WhatsApp number already exists.';
  static const String importFilterValid = 'Valid';
  static const String importFilterWarnings = 'Warnings';
  static const String importFilterCorrection = 'Needs correction';
  static const String importFilterDuplicates = 'Duplicates';
  static const String importSummaryImported = 'Imported';
  static const String importSummarySkipped = 'Skipped';
  static const String importSummaryFailed = 'Failed';
  static const String importNoValidRows =
      'No valid rows are available to import.';
  static const String batchFeeLabel = 'Batch fee';
  static const String continueWithGoogle = 'Continue with Google';
  static const String signInWithGoogle = 'Sign in with Google';
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
  static const String firestorePermissionDenied =
      'This action was denied by Firestore security rules. '
      'Deploy the latest rules and try again.';

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
  static const String sectionMotion = 'Motion and loading';
  static const String sampleStatLabel = 'Collected';
  static const String sampleStatValue = '12,500';
  static const String sampleEmptyMessage = 'No items to display.';
  static const String sampleSectionTitle = 'Section title';
  static const String sampleFieldLabel = 'Branch name';
  static const String sampleFieldHint = 'Enter branch name';
}
