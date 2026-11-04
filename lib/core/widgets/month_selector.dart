import 'package:feemanager/core/constants/app_durations.dart';
import 'package:feemanager/core/constants/app_spacing.dart';
import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/theme/app_colors.dart';
import 'package:feemanager/core/theme/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Previous and next month control with picker dialog.
class MonthSelector extends StatefulWidget {
  /// Creates a month selector starting at [initialMonth].
  const MonthSelector({
    required this.initialMonth,
    required this.onChanged,
    super.key,
  });

  /// Initial month (day portion ignored).
  final DateTime initialMonth;

  /// Called when the user selects a different month.
  final ValueChanged<DateTime> onChanged;

  @override
  State<MonthSelector> createState() => _MonthSelectorState();
}

class _MonthSelectorState extends State<MonthSelector> {
  late DateTime _month;
  final DateFormat _format = DateFormat('MMMM yyyy');

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.initialMonth.year, widget.initialMonth.month);
  }

  @override
  void didUpdateWidget(MonthSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = DateTime(widget.initialMonth.year, widget.initialMonth.month);
    if (next.year != _month.year || next.month != _month.month) {
      _month = next;
    }
  }

  void _shift(int delta) {
    final next = DateTime(_month.year, _month.month + delta);
    setState(() => _month = next);
    widget.onChanged(next);
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _month,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
      helpText: AppStrings.selectMonth,
    );
    if (picked == null || !mounted) {
      return;
    }
    final normalized = DateTime(picked.year, picked.month);
    setState(() => _month = normalized);
    widget.onChanged(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: AppStrings.previousMonth,
          onPressed: () => _shift(-1),
          icon: Icon(Icons.chevron_left, color: colors.copper),
        ),
        Expanded(
          child: InkWell(
            onTap: _pickMonth,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: AnimatedSwitcher(
                duration: AppMotion.duration(
                  context,
                  AppDurations.listCrossFade,
                ),
                switchInCurve: AppDurations.easeOut,
                switchOutCurve: AppDurations.easeOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.08, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _format.format(_month),
                  key: ValueKey<String>(_format.format(_month)),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: AppStrings.nextMonth,
          onPressed: () => _shift(1),
          icon: Icon(Icons.chevron_right, color: colors.copper),
        ),
      ],
    );
  }
}
