import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_text_theme.dart';
import 'package:feemanager/core/widgets/app_snack_bar.dart';
import 'package:feemanager/core/widgets/app_text_field.dart';
import 'package:feemanager/core/widgets/confirm_dialog.dart';
import 'package:feemanager/core/widgets/empty_state.dart';
import 'package:feemanager/core/widgets/gradient_button.dart';
import 'package:feemanager/core/widgets/kalaika_async_body.dart';
import 'package:feemanager/core/widgets/kalaika_card.dart';
import 'package:feemanager/core/widgets/kalaika_logo.dart';
import 'package:feemanager/core/widgets/kalaika_progress_indicator.dart';
import 'package:feemanager/core/widgets/kalaika_skeleton.dart';
import 'package:feemanager/core/widgets/loading_overlay.dart';
import 'package:feemanager/core/widgets/month_selector.dart';
import 'package:feemanager/core/widgets/ornamental_divider.dart';
import 'package:feemanager/core/widgets/outlined_copper_button.dart';
import 'package:feemanager/core/widgets/section_header.dart';
import 'package:feemanager/core/widgets/stat_tile.dart';
import 'package:feemanager/core/widgets/status_chip.dart';
import 'package:flutter/material.dart';

/// Debug gallery of shared UI components (M1 acceptance).
class StyleGuidePage extends StatefulWidget {
  /// Creates the design system gallery.
  const StyleGuidePage({super.key});

  @override
  State<StyleGuidePage> createState() => _StyleGuidePageState();
}

class _StyleGuidePageState extends State<StyleGuidePage> {
  var _loading = false;
  var _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.styleGuideTitle)),
      body: LoadingOverlay(
        isLoading: _loading,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          children: <Widget>[
            const Center(child: KalaikaLogo(size: 140)),
            const OrnamentalDivider(),
            _Section(
              title: AppStrings.sectionTypography,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Display', style: theme.displayLarge),
                  Text('Headline', style: theme.headlineMedium),
                  Text('Title', style: theme.titleLarge),
                  Text('Body', style: theme.bodyLarge),
                  Text('Label', style: theme.labelMedium),
                ],
              ),
            ),
            _Section(
              title: AppStrings.sectionButtons,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  GradientButton(
                    label: AppStrings.continueWithGoogle,
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedCopperButton(
                    label: AppStrings.cancel,
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppSpacing.md),
                  GradientButton(
                    label: AppStrings.save,
                    isLoading: true,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            _Section(
              title: AppStrings.sectionCards,
              child: KalaikaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SectionHeader(
                      title: AppStrings.sampleSectionTitle,
                      trailing: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert),
                      ),
                    ),
                    const StatTile(
                      label: AppStrings.sampleStatLabel,
                      value: 'Rs. ${AppStrings.sampleStatValue}',
                      icon: Icons.payments_outlined,
                    ),
                  ],
                ),
              ),
            ),
            const _Section(
              title: AppStrings.sectionInputs,
              child: AppTextField(
                label: AppStrings.sampleFieldLabel,
                hint: AppStrings.sampleFieldHint,
              ),
            ),
            _Section(
              title: AppStrings.sectionMonthSelector,
              child: MonthSelector(
                initialMonth: _selectedMonth,
                onChanged: (value) {
                  setState(() => _selectedMonth = value);
                },
              ),
            ),
            const _Section(
              title: AppStrings.sectionStatus,
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: <Widget>[
                  StatusChip(status: FeeDisplayStatus.unpaid),
                  StatusChip(status: FeeDisplayStatus.pendingSend),
                  StatusChip(
                    status: FeeDisplayStatus.sent,
                    sentLabel: 'Sent on 12 Oct',
                  ),
                ],
              ),
            ),
            _Section(
              title: AppStrings.sectionMotion,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      KalaikaProgressIndicator(
                        size: KalaikaProgressSize.small,
                      ),
                      KalaikaProgressIndicator(),
                      KalaikaProgressIndicator(
                        size: KalaikaProgressSize.large,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const KalaikaListRowSkeleton(),
                  const SizedBox(height: AppSpacing.md),
                  KalaikaAsyncBody(
                    phase: _loading
                        ? KalaikaAsyncPhase.refreshing
                        : KalaikaAsyncPhase.ready,
                    child: KalaikaCard(
                      child: Text(
                        AppStrings.sampleSectionTitle,
                        style: theme.titleMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _Section(
              title: AppStrings.sectionFeedback,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  EmptyState(
                    message: AppStrings.sampleEmptyMessage,
                    actionLabel: AppStrings.createBranch,
                    onAction: () {},
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GradientButton(
                    label: 'Show snack bar',
                    onPressed: () {
                      AppSnackBar.showError(
                        context,
                        AppStrings.receiptGenerateFailed,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedCopperButton(
                    label: 'Show confirm dialog',
                    onPressed: () async {
                      await ConfirmDialog.show(
                        context,
                        title: AppStrings.confirm,
                        message: AppStrings.sampleEmptyMessage,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedCopperButton(
                    label: 'Toggle loading overlay',
                    onPressed: () {
                      setState(() => _loading = !_loading);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.textScalerOf(context).scale(
                AppTextTheme.bodySize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionHeader(title: title),
          child,
        ],
      ),
    );
  }
}
