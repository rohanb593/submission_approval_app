import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:submission_approval_app/api/models/app_user.dart';

/// Persists the session issued by `/auth/login(/verify)`: the JWT plus the
/// `AppUser` it belongs to (the token itself carries only `user_id`/`role`,
/// see `backend/internal/auth/jwt.go` — no email, so the user is cached
/// app-side rather than decoded from the token). Exposes both synchronously
/// (after [load]) so `ApiClient` can attach the token without an await, and
/// so the app-level auth gate can react immediately to login/logout.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final FlutterSecureStorage _storage;
  final ValueNotifier<String?> _token = ValueNotifier(null);
  final ValueNotifier<AppUser?> _user = ValueNotifier(null);

  ValueListenable<String?> get token => _token;
  ValueListenable<AppUser?> get user => _user;

  String? get currentToken => _token.value;
  AppUser? get currentUser => _user.value;

  Future<void> load() async {
    final results = await Future.wait([
      _storage.read(key: _tokenKey),
      _storage.read(key: _userKey),
    ]);
    _token.value = results[0];
    final rawUser = results[1];
    _user.value = rawUser == null
        ? null
        : AppUser.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
  }

  Future<void> save(String token, AppUser user) async {
    _token.value = token;
    _user.value = user;
    await Future.wait([
      _storage.write(key: _tokenKey, value: token),
      _storage.write(
        key: _userKey,
        value: jsonEncode({
          'id': user.id,
          'email': user.email,
          'role': user.role.toJson(),
          'created_at': user.createdAt?.toIso8601String(),
        }),
      ),
    ]);
  }

  Future<void> clear() async {
    _token.value = null;
    _user.value = null;
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _userKey),
    ]);
  }
}
