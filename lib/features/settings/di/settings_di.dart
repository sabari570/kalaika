import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/features/auth/domain/repositories/auth_repository.dart';
import 'package:feemanager/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:feemanager/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:feemanager/features/settings/domain/repositories/settings_repository.dart';
import 'package:feemanager/features/settings/domain/usecases/update_settings.dart';
import 'package:feemanager/features/settings/domain/usecases/watch_user_settings.dart';
import 'package:feemanager/features/settings/presentation/cubit/institute_settings_form_cubit.dart';
import 'package:feemanager/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:feemanager/features/settings/presentation/cubit/template_settings_form_cubit.dart';

/// Registers settings feature dependencies.
void configureSettingsDependencies() {
  sl
    ..registerLazySingleton(SettingsRemoteDataSource.new)
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(
        remoteDataSource: sl<SettingsRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton(
      () => WatchUserSettings(
        sl<AuthRepository>(),
        sl<SettingsRepository>(),
      ),
    )
    ..registerLazySingleton(
      () => UpdateInstituteSettings(sl<SettingsRepository>()),
    )
    ..registerLazySingleton(
      () => UpdateMessageTemplate(sl<SettingsRepository>()),
    )
    ..registerLazySingleton(
      () => ResetMessageTemplate(sl<SettingsRepository>()),
    )
    ..registerFactory(
      () => SettingsCubit(
        watchUserSettings: sl<WatchUserSettings>(),
      ),
    )
    ..registerFactory(
      () => InstituteSettingsFormCubit(
        watchUserSettings: sl<WatchUserSettings>(),
        updateInstituteSettings: sl<UpdateInstituteSettings>(),
      ),
    )
    ..registerFactory(
      () => TemplateSettingsFormCubit(
        watchUserSettings: sl<WatchUserSettings>(),
        updateMessageTemplate: sl<UpdateMessageTemplate>(),
        resetMessageTemplate: sl<ResetMessageTemplate>(),
      ),
    );
}
