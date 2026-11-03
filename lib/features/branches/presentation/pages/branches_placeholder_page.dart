import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

/// Branches tab placeholder until M3.
class BranchesPlaceholderPage extends StatelessWidget {
  /// Creates the branches placeholder.
  const BranchesPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Center(
          child: Text(
            AppStrings.branchesPlaceholder,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
