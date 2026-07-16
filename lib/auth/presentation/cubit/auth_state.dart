import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final bool isAuthenticated;
  final bool obscurePassword;
  final bool rememberMe;
  final String? errorMessage;
  final String? userEmail;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.obscurePassword = true,
    this.rememberMe = false,
    this.errorMessage,
    this.userEmail,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    bool? obscurePassword,
    bool? rememberMe,
    String? errorMessage,
    String? userEmail,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      rememberMe: rememberMe ?? this.rememberMe,
      errorMessage: errorMessage,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isAuthenticated,
    obscurePassword,
    rememberMe,
    errorMessage,
    userEmail,
  ];
}