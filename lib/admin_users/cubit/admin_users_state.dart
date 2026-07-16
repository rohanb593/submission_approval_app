part of 'admin_users_cubit.dart';

enum AdminUsersStatus { initial, loading, success, failure }

class AdminUsersState extends Equatable {
  const AdminUsersState({
    this.status = AdminUsersStatus.initial,
    this.users = const [],
    this.errorMessage,
  });

  final AdminUsersStatus status;
  final List<AppUser> users;
  final String? errorMessage;

  AdminUsersState copyWith({
    AdminUsersStatus? status,
    List<AppUser>? users,
    String? errorMessage,
  }) {
    return AdminUsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, errorMessage];
}
