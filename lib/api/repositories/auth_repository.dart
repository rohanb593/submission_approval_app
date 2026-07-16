import 'package:submission_approval_app/api/api_client.dart';
import 'package:submission_approval_app/api/models/app_user.dart';
import 'package:submission_approval_app/api/token_storage.dart';

/// Result of `POST /auth/login`: either a completed session (2FA disabled)
/// or a pending challenge that must be confirmed via
/// [AuthRepository.verifyLogin] (2FA enabled). See `loginResponse` in
/// `backend/internal/httpapi/auth_handlers.go`.
sealed class LoginResult {
  const LoginResult();
}

class LoginChallenge extends LoginResult {
  const LoginChallenge(this.challengeId);
  final String challengeId;
}

class LoginSuccess extends LoginResult {
  const LoginSuccess(this.user);
  final AppUser user;
}

class AuthRepository {
  AuthRepository({
    required this._apiClient,
    required this._tokenStorage,
  });

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AppUser? get currentUser => _tokenStorage.currentUser;

  bool get isAuthenticated => _tokenStorage.currentToken != null;

  Future<void> restoreSession() => _tokenStorage.load();

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final json =
        await _apiClient.post(
              '/auth/login',
              body: {'email': email, 'password': password},
            )
            as Map<String, dynamic>;

    final challengeId = json['challenge_id'] as String?;
    if (challengeId != null) {
      return LoginChallenge(challengeId);
    }
    return LoginSuccess(await _completeLogin(json));
  }

  Future<LoginResult> verifyLogin({
    required String challengeId,
    required String code,
  }) async {
    final json =
        await _apiClient.post(
              '/auth/login/verify',
              body: {'challenge_id': challengeId, 'code': code},
            )
            as Map<String, dynamic>;
    return LoginSuccess(await _completeLogin(json));
  }

  Future<AppUser> _completeLogin(Map<String, dynamic> json) async {
    final token = json['token'] as String;
    final user = AppUser.fromJson(json['user'] as Map<String, dynamic>);
    await _tokenStorage.save(token, user);
    return user;
  }

  Future<void> logout() => _tokenStorage.clear();
}
