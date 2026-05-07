enum LoginStatus { initial, loading, success, error }

class LoginState {
  final bool isValidMobile;
  final LoginStatus status;

  LoginState({
    this.isValidMobile = false,
    this.status = LoginStatus.initial,
  });

  LoginState copyWith({
    bool? isValidMobile,
    LoginStatus? status,
  }) {
    return LoginState(
      isValidMobile: isValidMobile ?? this.isValidMobile,
      status: status ?? this.status,
    );
  }
}