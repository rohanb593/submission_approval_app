import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:submission_approval_app/api/api_exception.dart';
import 'package:submission_approval_app/api/repositories/auth_repository.dart';

part 'login_state.dart';

/// Drives the two-step login flow (`POST /auth/login` then, when 2FA is
/// enabled, `POST /auth/login/verify`). On success [AuthRepository] persists
/// the session itself, so this cubit doesn't need a "success" state — the
/// app-level auth gate reacts to [AuthRepository.currentUser] changing.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required this._authRepository}) : super(const LoginState());

  final AuthRepository _authRepository;

  Future<void> submitCredentials({
    required String email,
    required String password,
  }) async {
    emit(const LoginState(isSubmitting: true));
    try {
      final result = await _authRepository.login(
        email: email,
        password: password,
      );
      switch (result) {
        case LoginChallenge(:final challengeId):
          emit(LoginState(step: AuthStep.otp, challengeId: challengeId));
        case LoginSuccess():
          emit(const LoginState());
      }
    } on ApiException catch (e) {
      emit(LoginState(errorMessage: e.message));
    }
  }

  Future<void> submitOtp(String code) async {
    final challengeId = state.challengeId;
    if (challengeId == null) return;
    emit(
      LoginState(
        step: AuthStep.otp,
        isSubmitting: true,
        challengeId: challengeId,
      ),
    );
    try {
      await _authRepository.verifyLogin(challengeId: challengeId, code: code);
      emit(const LoginState());
    } on ApiException catch (e) {
      emit(
        LoginState(
          step: AuthStep.otp,
          errorMessage: e.message,
          challengeId: challengeId,
        ),
      );
    }
  }

  void backToCredentials() => emit(const LoginState());
}
