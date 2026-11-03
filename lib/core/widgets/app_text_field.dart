import 'package:feemanager/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Filled text field styled for Kalaika forms.
class AppTextField extends StatelessWidget {
  /// Creates a themed text field.
  const AppTextField({
    this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    super.key,
  });

  /// Optional text editing controller.
  final TextEditingController? controller;

  /// Field label.
  final String? label;

  /// Hint when empty.
  final String? hint;

  /// Keyboard type override.
  final TextInputType? keyboardType;

  /// Maximum lines (1 for single line).
  final int maxLines;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: colors.cream,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}
