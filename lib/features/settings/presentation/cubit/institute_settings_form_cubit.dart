import 'dart:async';

import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/usecase/usecase.dart';
import 'package:feemanager/features/fees/domain/entities/institute_settings.dart';
import 'package:feemanager/features/settings/domain/entities/user_settings_view.dart';
import 'package:feemanager/features/settings/domain/usecases/update_settings.dart';
import 'package:feemanager/features/settings/domain/usecases/watch_user_settings.dart';
import 'package:feemanager/features/settings/presentation/cubit/institute_settings_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Edits institute details on the user profile.
class InstituteSettingsFormCubit extends Cubit<InstituteSettingsFormState> {
  /// Creates the cubit.
  InstituteSettingsFormCubit({
    required this.watchUserSettings,
    required this.updateInstituteSettings,
  }) : super(const InstituteSettingsFormLoading());

  final WatchUserSettings watchUserSettings;
  final UpdateInstituteSettings updateInstituteSettings;
  StreamSubscription<Result<UserSettingsView>>? _subscription;

  /// Loads institute values from Firestore.
  void started() {
    unawaited(_subscription?.cancel());
    emit(const InstituteSettingsFormLoading());
    _subscription = watchUserSettings(const NoParams()).listen(
      (result) {
        switch (result) {
          case Success(:final value):
            emit(InstituteSettingsFormReady(institute: value.institute));
          case Err():
            emit(
              const InstituteSettingsFormFailure(
                AppStrings.settingsLoadFailed,
              ),
            );
        }
      },
      onError: (_) {
        emit(
          const InstituteSettingsFormFailure(AppStrings.settingsLoadFailed),
        );
      },
    );
  }

  void nameChanged(String value) {
    final current = state;
    if (current is! InstituteSettingsFormReady) {
      return;
    }
    emit(
      current.copyWith(
        institute: current.institute.copyWith(name: value),
        clearNameError: true,
      ),
    );
  }

  void taglineChanged(String value) {
    _updateReady(
      (institute) => institute.copyWith(tagline: value),
    );
  }

  void phoneChanged(String value) {
    _updateReady(
      (institute) => institute.copyWith(phone: value),
    );
  }

  void signatoryChanged(String value) {
    _updateReady(
      (institute) => institute.copyWith(signatory: value),
    );
  }

  void footerChanged(String value) {
    _updateReady(
      (institute) => institute.copyWith(footerNote: value),
    );
  }

  void addressChanged(String value) {
    final lines = value
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    _updateReady(
      (institute) => institute.copyWith(addressLines: lines),
    );
  }

  /// Persists institute details; returns null on success or an error message.
  Future<String?> save() async {
    final current = state;
    if (current is! InstituteSettingsFormReady || current.isSaving) {
      return null;
    }
    if (current.institute.name.trim().isEmpty) {
      emit(
        current.copyWith(
          nameError: AppStrings.settingsInstituteNameRequired,
        ),
      );
      return AppStrings.settingsInstituteNameRequired;
    }
    emit(current.copyWith(isSaving: true));
    final result = await updateInstituteSettings(
      UpdateInstituteSettingsParams(institute: current.institute),
    );
    switch (result) {
      case Success<void>():
        emit(current.copyWith(isSaving: false));
        return null;
      case Err(:final failure):
        emit(current.copyWith(isSaving: false));
        return failure.message;
    }
  }

  void _updateReady(
    InstituteSettings Function(InstituteSettings institute) transform,
  ) {
    final current = state;
    if (current is! InstituteSettingsFormReady || current.isSaving) {
      return;
    }
    emit(
      current.copyWith(
        institute: transform(current.institute),
      ),
    );
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
