import 'package:feemanager/core/di/service_locator.dart';
import 'package:feemanager/features/batches/domain/usecases/get_batch.dart';
import 'package:feemanager/features/students/data/datasources/student_remote_datasource.dart';
import 'package:feemanager/features/students/data/repositories/student_repository_impl.dart';
import 'package:feemanager/features/students/domain/repositories/student_repository.dart';
import 'package:feemanager/features/students/domain/usecases/create_student.dart';
import 'package:feemanager/features/students/domain/usecases/get_student.dart';
import 'package:feemanager/features/students/domain/usecases/set_student_active.dart';
import 'package:feemanager/features/students/domain/usecases/student_import_usecases.dart';
import 'package:feemanager/features/students/domain/usecases/update_student.dart';
import 'package:feemanager/features/students/domain/usecases/watch_students.dart';
import 'package:feemanager/features/students/presentation/cubit/import_students_cubit.dart';
import 'package:feemanager/features/students/presentation/cubit/student_detail_cubit.dart';
import 'package:feemanager/features/students/presentation/cubit/student_form_cubit.dart';
import 'package:feemanager/features/students/presentation/cubit/student_list_cubit.dart';

/// Registers student feature dependencies.
void configureStudentsDependencies() {
  sl
    ..registerLazySingleton(StudentRemoteDataSource.new)
    ..registerLazySingleton<StudentRepository>(
      () => StudentRepositoryImpl(
        remoteDataSource: sl<StudentRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton(() => WatchStudents(sl<StudentRepository>()))
    ..registerLazySingleton(() => GetStudent(sl<StudentRepository>()))
    ..registerLazySingleton(() => CreateStudent(sl<StudentRepository>()))
    ..registerLazySingleton(() => UpdateStudent(sl<StudentRepository>()))
    ..registerLazySingleton(() => SetStudentActive(sl<StudentRepository>()))
    ..registerLazySingleton(() => HasDuplicateStudent(sl<StudentRepository>()))
    ..registerLazySingleton(() => ParseStudentImport(sl<StudentRepository>()))
    ..registerLazySingleton(() => ImportStudents(sl<StudentRepository>()))
    ..registerLazySingleton(() => BuildStudentTemplate(sl<StudentRepository>()))
    ..registerLazySingleton(
      () => GetStudentPaymentHistory(sl<StudentRepository>()),
    )
    ..registerFactory(
      () => StudentListCubit(
        watchStudents: sl<WatchStudents>(),
        setStudentActive: sl<SetStudentActive>(),
      ),
    )
    ..registerFactory(
      () => StudentFormCubit(
        getBatch: sl<GetBatch>(),
        getStudent: sl<GetStudent>(),
        createStudent: sl<CreateStudent>(),
        updateStudent: sl<UpdateStudent>(),
        hasDuplicateStudent: sl<HasDuplicateStudent>(),
      ),
    )
    ..registerFactory(
      () => StudentDetailCubit(
        getStudent: sl<GetStudent>(),
        getPaymentHistory: sl<GetStudentPaymentHistory>(),
      ),
    )
    ..registerFactory(
      () => ImportStudentsCubit(
        parseImport: sl<ParseStudentImport>(),
        importStudents: sl<ImportStudents>(),
        buildTemplate: sl<BuildStudentTemplate>(),
      ),
    );
}
