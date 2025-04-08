enum LoginStatus { initial, loading, success, failure }

class LoginState {
  final LoginStatus status;
  final String? error;

  LoginState({required this.status, this.error});

  factory LoginState.initial() => LoginState(status: LoginStatus.initial);
  factory LoginState.loading() => LoginState(status: LoginStatus.loading);
  factory LoginState.success() => LoginState(status: LoginStatus.success);
  factory LoginState.failure(String message) =>
      LoginState(status: LoginStatus.failure, error: message);
}
