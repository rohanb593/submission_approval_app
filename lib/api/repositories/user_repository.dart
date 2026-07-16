import 'package:submission_approval_app/api/api_client.dart';
import 'package:submission_approval_app/api/models/app_role.dart';
import 'package:submission_approval_app/api/models/app_user.dart';

/// Wraps the admin-only `/admin/users/*` endpoints — see
/// `backend/internal/httpapi/user_handlers.go`. Provisions accounts; there
/// is no public self-signup.
class UserRepository {
  UserRepository({required this._apiClient});

  final ApiClient _apiClient;

  Future<List<AppUser>> list() async {
    final json = await _apiClient.get('/admin/users') as List<dynamic>;
    return json.cast<Map<String, dynamic>>().map(AppUser.fromJson).toList();
  }

  Future<AppUser> create({
    required String email,
    required String password,
    required AppRole role,
  }) async {
    final json =
        await _apiClient.post(
              '/admin/users',
              body: {
                'email': email,
                'password': password,
                'role': role.toJson(),
              },
            )
            as Map<String, dynamic>;
    return AppUser.fromJson(json);
  }

  Future<AppUser> updateRole(String id, AppRole role) async {
    final json =
        await _apiClient.put(
              '/admin/users/$id/role',
              body: {'role': role.toJson()},
            )
            as Map<String, dynamic>;
    return AppUser.fromJson(json);
  }

  Future<void> delete(String id) => _apiClient.delete('/admin/users/$id');
}
