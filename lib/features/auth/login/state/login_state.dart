enum LoginStatus { initial, loading, success, failure }

class LoginState {
  final String username;
  final String password;
  final String? usernameError;
  final String? passwordError;
  final bool obscurePassword;
  final bool rememberMe;
  final LoginStatus status;
  final String? errorMessage;

  const LoginState({
    this.username = '',
    this.password = '',
    this.usernameError,
    this.passwordError,
    this.obscurePassword = true,
    this.rememberMe = false,
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  LoginState copyWith({
    String? username,
    String? password,
    String? usernameError,
    String? passwordError,
    bool? obscurePassword,
    bool? rememberMe,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      usernameError: usernameError,
      passwordError: passwordError,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      rememberMe: rememberMe ?? this.rememberMe,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoginState &&
        other.username == username &&
        other.password == password &&
        other.usernameError == usernameError &&
        other.passwordError == passwordError &&
        other.obscurePassword == obscurePassword &&
        other.rememberMe == rememberMe &&
        other.status == status &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      username,
      password,
      usernameError,
      passwordError,
      obscurePassword,
      rememberMe,
      status,
      errorMessage,
    );
  }
}