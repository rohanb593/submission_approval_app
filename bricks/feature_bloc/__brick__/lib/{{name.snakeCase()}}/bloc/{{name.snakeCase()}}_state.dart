part of '{{name.snakeCase()}}_bloc.dart';

enum {{name.pascalCase()}}Status { initial, loading, success, failure }

final class {{name.pascalCase()}}State extends Equatable {
  const {{name.pascalCase()}}State({
    this.status = {{name.pascalCase()}}Status.initial,
    this.errorMessage,
  });

  final {{name.pascalCase()}}Status status;
  final String? errorMessage;

  {{name.pascalCase()}}State copyWith({
    {{name.pascalCase()}}Status? status,
    String? errorMessage,
  }) {
    return {{name.pascalCase()}}State(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
