import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:submission_approval_app/api/api_exception.dart';
import 'package:submission_approval_app/api/models/app_role.dart';
import 'package:submission_approval_app/api/models/app_user.dart';
import 'package:submission_approval_app/api/repositories/user_repository.dart';

part 'admin_users_state.dart';

/// Wraps `/admin/users/*` — account provisioning is admin-only, there's no
/// public self-signup (see `backend/internal/httpapi/user_handlers.go`).
class AdminUsersCubit extends Cubit<AdminUsersState> {
  AdminUsersCubit({required UserRepository userRepository})
    : _repo = userRepository,
      super(const AdminUsersState());

  final UserRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: AdminUsersStatus.loading));
    try {
      final users = await _repo.list();
      emit(state.copyWith(status: AdminUsersStatus.success, users: users));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: AdminUsersStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<String?> create({
    required String email,
    required String password,
    required AppRole role,
  }) async {
    try {
      await _repo.create(email: email, password: password, role: role);
      await load();
      return null;
    } on ApiException catch (e) {
      return e.fields.isNotEmpty ? e.fields.values.first : e.message;
    }
  }

  Future<String?> updateRole(String id, AppRole role) async {
    try {
      await _repo.updateRole(id, role);
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> delete(String id) async {
    try {
      await _repo.delete(id);
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }
}
