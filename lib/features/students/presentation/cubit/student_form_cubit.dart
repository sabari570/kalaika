import 'package:feemanager/core/constants/app_strings.dart';
import 'package:feemanager/core/error/result.dart';
import 'package:feemanager/core/utils/age_utils.dart';
import 'package:feemanager/core/utils/phone_utils.dart';
import 'package:feemanager/features/batches/domain/usecases/get_batch.dart';
import 'package:feemanager/features/students/domain/entities/student_draft.dart';
import 'package:feemanager/features/students/domain/usecases/create_student.dart';
import 'package:feemanager/features/students/domain/usecases/get_student.dart';
import 'package:feemanager/features/students/domain/usecases/student_import_usecases.dart';
import 'package:feemanager/features/students/domain/usecases/update_student.dart';
import 'package:feemanager/features/students/presentation/cubit/student_form_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Create and edit student form logic.
class StudentFormCubit extends Cubit<StudentFormState> {
  /// Creates the cubit.
  StudentFormCubit({
    required this._getBatch,
    required this._getStudent,
    required this._createStudent,
    required this._updateStudent,
    required this._hasDuplicateStudent,
  }) : super(
         StudentFormReady(
           draft: _emptyDraft(),
           isEditing: false,
           sameAsPhone: false,
         ),
       );

  final GetBatch _getBatch;
  final GetStudent _getStudent;
  final CreateStudent _createStudent;
  final UpdateStudent _updateStudent;
  final HasDuplicateStudent _hasDuplicateStudent;

  String? _branchId;
  String? _batchId;
  String? _studentId;
  String _phoneInput = '';
  String _whatsappInput = '';

  static StudentDraft _emptyDraft() {
    return const StudentDraft(
      fullName: '',
      phoneNumber: null,
      whatsappNumber: '',
      dateOfBirth: null,
      age: null,
      guardianName: null,
      guardianPhone: null,
      address: null,
      monthlyFee: 0,
    );
  }

  /// Prepares a create form.
  Future<void> initCreate(String branchId, String batchId) async {
    _branchId = branchId;
    _batchId = batchId;
    _studentId = null;
    _phoneInput = '';
    _whatsappInput = '';
    final batchResult = await _getBatch(
      GetBatchParams(branchId: branchId, batchId: batchId),
    );
    final fee = switch (batchResult) {
      Success(:final value) => value.defaultFee,
      Err() => 0,
    };
    emit(
      StudentFormReady(
        isEditing: false,
        sameAsPhone: false,
        batchDefaultFee: fee,
        draft: StudentDraft(
          fullName: '',
          phoneNumber: null,
          whatsappNumber: '',
          dateOfBirth: null,
          age: null,
          guardianName: null,
          guardianPhone: null,
          address: null,
          monthlyFee: fee,
        ),
      ),
    );
  }

  /// Loads an existing student for editing.
  Future<void> initEdit(
    String branchId,
    String batchId,
    String studentId,
  ) async {
    _branchId = branchId;
    _batchId = batchId;
    _studentId = studentId;
    final result = await _getStudent(
      GetStudentParams(
        branchId: branchId,
        batchId: batchId,
        studentId: studentId,
      ),
    );
    switch (result) {
      case Success(:final value):
        _phoneInput = value.phoneNumber ?? '';
        _whatsappInput = value.whatsappNumber;
        emit(
          StudentFormReady(
            isEditing: true,
            sameAsPhone: false,
            existingStudent: value,
            draft: StudentDraft(
              fullName: value.fullName,
              phoneNumber: value.phoneNumber,
              whatsappNumber: value.whatsappNumber,
              dateOfBirth: value.dateOfBirth,
              age: value.age,
              guardianName: value.guardianName,
              guardianPhone: value.guardianPhone,
              address: value.address,
              monthlyFee: value.monthlyFee,
            ),
          ),
        );
      case Err(:final failure):
        emit(StudentFormFailure(failure.message, _emptyDraft()));
    }
  }

  void fullNameChanged(String value) => _mutate(
    (draft) => StudentDraft(
      fullName: value,
      phoneNumber: draft.phoneNumber,
      whatsappNumber: draft.whatsappNumber,
      dateOfBirth: draft.dateOfBirth,
      age: draft.age,
      guardianName: draft.guardianName,
      guardianPhone: draft.guardianPhone,
      address: draft.address,
      monthlyFee: draft.monthlyFee,
    ),
    clearNameError: true,
  );

  void phoneChanged(String value) {
    _phoneInput = value;
    final current = state;
    if (current is! StudentFormReady) {
      return;
    }
    if (current.sameAsPhone) {
      whatsappChanged(value);
    }
  }

  void whatsappChanged(String value) {
    _whatsappInput = value;
    _mutate(
      (draft) => StudentDraft(
        fullName: draft.fullName,
        phoneNumber: draft.phoneNumber,
        whatsappNumber: value,
        dateOfBirth: draft.dateOfBirth,
        age: draft.age,
        guardianName: draft.guardianName,
        guardianPhone: draft.guardianPhone,
        address: draft.address,
        monthlyFee: draft.monthlyFee,
      ),
      clearWhatsappError: true,
    );
  }

  void sameAsPhoneChanged({required bool enabled}) {
    final current = state;
    if (current is StudentFormReady) {
      emit(current.copyWith(sameAsPhone: enabled));
      if (enabled) {
        whatsappChanged(_phoneInput);
      }
    }
  }

  void dateOfBirthChanged(DateTime? value) {
    _mutate((draft) {
      final age = value == null
          ? draft.age
          : AgeUtils.ageFromDateOfBirth(value);
      return StudentDraft(
        fullName: draft.fullName,
        phoneNumber: draft.phoneNumber,
        whatsappNumber: draft.whatsappNumber,
        dateOfBirth: value,
        age: age,
        guardianName: draft.guardianName,
        guardianPhone: draft.guardianPhone,
        address: draft.address,
        monthlyFee: draft.monthlyFee,
      );
    });
  }

  void ageChanged(String value) {
    final current = state;
    if (current is! StudentFormReady || current.draft.dateOfBirth != null) {
      return;
    }
    final parsed = int.tryParse(value.trim());
    _mutate(
      (draft) => StudentDraft(
        fullName: draft.fullName,
        phoneNumber: draft.phoneNumber,
        whatsappNumber: draft.whatsappNumber,
        dateOfBirth: null,
        age: parsed,
        guardianName: draft.guardianName,
        guardianPhone: draft.guardianPhone,
        address: draft.address,
        monthlyFee: draft.monthlyFee,
      ),
    );
  }

  void guardianChanged(String value) => _mutate(
    (draft) => StudentDraft(
      fullName: draft.fullName,
      phoneNumber: draft.phoneNumber,
      whatsappNumber: draft.whatsappNumber,
      dateOfBirth: draft.dateOfBirth,
      age: draft.age,
      guardianName: value,
      guardianPhone: draft.guardianPhone,
      address: draft.address,
      monthlyFee: draft.monthlyFee,
    ),
  );

  void guardianPhoneChanged(String value) => _mutate(
    (draft) => StudentDraft(
      fullName: draft.fullName,
      phoneNumber: draft.phoneNumber,
      whatsappNumber: draft.whatsappNumber,
      dateOfBirth: draft.dateOfBirth,
      age: draft.age,
      guardianName: draft.guardianName,
      guardianPhone: value,
      address: draft.address,
      monthlyFee: draft.monthlyFee,
    ),
  );

  void addressChanged(String value) => _mutate(
    (draft) => StudentDraft(
      fullName: draft.fullName,
      phoneNumber: draft.phoneNumber,
      whatsappNumber: draft.whatsappNumber,
      dateOfBirth: draft.dateOfBirth,
      age: draft.age,
      guardianName: draft.guardianName,
      guardianPhone: draft.guardianPhone,
      address: value,
      monthlyFee: draft.monthlyFee,
    ),
  );

  void feeChanged(String value) {
    final fee = int.tryParse(value.trim()) ?? 0;
    _mutate(
      (draft) => StudentDraft(
        fullName: draft.fullName,
        phoneNumber: draft.phoneNumber,
        whatsappNumber: draft.whatsappNumber,
        dateOfBirth: draft.dateOfBirth,
        age: draft.age,
        guardianName: draft.guardianName,
        guardianPhone: draft.guardianPhone,
        address: draft.address,
        monthlyFee: fee,
      ),
      clearFeeError: true,
    );
  }

  void cancelPhoneConfirm() {
    final current = state;
    if (current is StudentFormPhoneConfirm) {
      emit(
        StudentFormReady(
          draft: current.draft,
          isEditing: current.isEditing,
          sameAsPhone: false,
        ),
      );
    }
  }

  /// Saves the student, optionally confirming an international number.
  Future<void> save({bool confirmInternationalPhone = false}) async {
    final current = state;
    if (current is StudentFormPhoneConfirm && confirmInternationalPhone) {
      await _persist(current.draft, current.isEditing);
      return;
    }
    if (current is! StudentFormReady) {
      return;
    }
    final built = _buildDraft(current);
    if (built == null) {
      return;
    }
    if (built.needsConfirm && !confirmInternationalPhone) {
      emit(
        StudentFormPhoneConfirm(
          draft: built.draft,
          isEditing: current.isEditing,
        ),
      );
      return;
    }
    await _persist(built.draft, current.isEditing);
  }

  Future<void> _persist(StudentDraft draft, bool isEditing) async {
    final branchId = _branchId;
    final batchId = _batchId;
    if (branchId == null || batchId == null) {
      return;
    }
    emit(StudentFormSaving(draft));
    final duplicate = await _hasDuplicateStudent(
      HasDuplicateStudentParams(
        branchId: branchId,
        batchId: batchId,
        fullName: draft.fullName,
        whatsappNumber: draft.whatsappNumber,
        excludeStudentId: _studentId,
      ),
    );
    if (duplicate case Success(:final value) when value) {
      emit(StudentFormFailure(AppStrings.studentDuplicate, draft));
      return;
    }
    final Result<dynamic> result;
    if (isEditing && _studentId != null) {
      result = await _updateStudent(
        UpdateStudentParams(
          branchId: branchId,
          batchId: batchId,
          studentId: _studentId!,
          draft: draft,
        ),
      );
    } else {
      result = await _createStudent(
        CreateStudentParams(
          branchId: branchId,
          batchId: batchId,
          draft: draft,
        ),
      );
    }
    switch (result) {
      case Success():
        emit(const StudentFormSuccess());
      case Err(:final failure):
        emit(StudentFormFailure(failure.message, draft));
    }
  }

  ({StudentDraft draft, bool needsConfirm})? _buildDraft(
    StudentFormReady ready,
  ) {
    String? phoneDigits;
    if (_phoneInput.trim().isNotEmpty) {
      final phoneResult = PhoneUtils.normalize(
        _phoneInput,
        bulkImport: false,
      );
      switch (phoneResult) {
        case PhoneNormalized(:final digits):
          phoneDigits = digits;
        case PhoneInvalid():
          _mutate(
            (draft) => draft,
            whatsappError: AppStrings.phoneInvalid,
          );
          return null;
        case PhoneNeedsConfirmation():
        case PhoneNeedsCorrection():
          break;
      }
    }
    var needsConfirm = false;
    late String whatsappDigits;
    final waResult = PhoneUtils.normalize(
      _whatsappInput,
      bulkImport: false,
    );
    switch (waResult) {
      case PhoneNormalized(:final digits):
        whatsappDigits = digits;
      case PhoneNeedsConfirmation(:final digits):
        whatsappDigits = digits;
        needsConfirm = true;
      case PhoneInvalid():
        emit(
          ready.copyWith(whatsappError: AppStrings.phoneInvalid),
        );
        return null;
      case PhoneNeedsCorrection():
        emit(
          ready.copyWith(whatsappError: AppStrings.phoneInvalid),
        );
        return null;
    }
    if (whatsappDigits.isEmpty) {
      emit(ready.copyWith(whatsappError: AppStrings.whatsappRequired));
      return null;
    }
    if (ready.draft.fullName.trim().isEmpty) {
      emit(ready.copyWith(nameError: AppStrings.studentNameRequired));
      return null;
    }
    if (ready.draft.monthlyFee <= 0) {
      emit(ready.copyWith(feeError: AppStrings.studentFeeInvalid));
      return null;
    }
    String? guardianPhone;
    final guardianRaw = ready.draft.guardianPhone ?? '';
    if (guardianRaw.trim().isNotEmpty) {
      final gp = PhoneUtils.normalize(guardianRaw, bulkImport: false);
      switch (gp) {
        case PhoneNormalized(:final digits):
          guardianPhone = digits;
        case PhoneNeedsConfirmation(:final digits):
          guardianPhone = digits;
          needsConfirm = true;
        case PhoneInvalid():
        case PhoneNeedsCorrection():
          guardianPhone = null;
      }
    }
    final draft = StudentDraft(
      fullName: ready.draft.fullName,
      phoneNumber: phoneDigits,
      whatsappNumber: whatsappDigits,
      dateOfBirth: ready.draft.dateOfBirth,
      age: ready.draft.dateOfBirth == null ? ready.draft.age : null,
      guardianName: ready.draft.guardianName,
      guardianPhone: guardianPhone,
      address: ready.draft.address,
      monthlyFee: ready.draft.monthlyFee,
    );
    return (draft: draft, needsConfirm: needsConfirm);
  }

  void _mutate(
    StudentDraft Function(StudentDraft draft) transform, {
    bool clearNameError = false,
    bool clearWhatsappError = false,
    bool clearFeeError = false,
    String? whatsappError,
  }) {
    final current = state;
    if (current is StudentFormReady) {
      emit(
        current.copyWith(
          draft: transform(current.draft),
          nameError: clearNameError ? null : current.nameError,
          whatsappError: whatsappError ?? (clearWhatsappError
              ? null
              : current.whatsappError),
          feeError: clearFeeError ? null : current.feeError,
        ),
      );
    }
  }
}
