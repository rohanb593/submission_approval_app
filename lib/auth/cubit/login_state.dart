part of 'login_cubit.dart';

enum AuthStep { credentials, otp }

class LoginState extends Equatable {
  const LoginState({
    this.step = AuthStep.credentials,
    this.isSubmitting = false,
    this.errorMessage,
    this.challengeId,
  });

  final AuthStep step;
  final bool isSubmitting;
  final String? errorMessage;
  final String? challengeId;

  @override
  List<Object?> get props => [step, isSubmitting, errorMessage, challengeId];
}
