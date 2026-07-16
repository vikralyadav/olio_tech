import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/is_logged_in_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final IsLoggedInUseCase isLoggedInUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.isLoggedInUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthState());

  //--------------------------------------------------
  // Login
  //--------------------------------------------------

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(
      isLoading: true,
      errorMessage: null,
    ));

    final success = await loginUseCase(
      email: email,
      password: password,
      rememberMe: state.rememberMe,
    );

    if (success) {
      emit(state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userEmail: email,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: "Invalid email or password",
      ));
    }
  }

  //--------------------------------------------------
  // Register
  //--------------------------------------------------

  Future<void> register({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(isLoading: true));

    await registerUseCase(
      user: User(email: email),
      password: password,
    );

    emit(state.copyWith(
      isLoading: false,
      errorMessage: null,
    ));
  }

  //--------------------------------------------------
  // Logout
  //--------------------------------------------------

  Future<void> logout() async {
    await logoutUseCase();

    emit(
      state.copyWith(
        isAuthenticated: false,
      ),
    );
  }

  //--------------------------------------------------
  // Splash Check
  //--------------------------------------------------

  Future<void> checkLoginStatus() async {
    final loggedIn = await isLoggedInUseCase();
    final user = await getCurrentUserUseCase();

    emit(
      state.copyWith(
        isAuthenticated: loggedIn,
        userEmail: user?.email,
      ),
    );
  }

  //--------------------------------------------------
  // Password Visibility
  //--------------------------------------------------

  void togglePasswordVisibility() {
    emit(
      state.copyWith(
        obscurePassword: !state.obscurePassword,
      ),
    );
  }

  //--------------------------------------------------
  // Remember Me
  //--------------------------------------------------

  void toggleRememberMe(bool value) {
    emit(
      state.copyWith(
        rememberMe: value,
      ),
    );
  }

  //--------------------------------------------------
  // Forgot Password (Dummy)
  //--------------------------------------------------

  Future<void> forgotPassword(String email) async {
    emit(
      state.copyWith(
        errorMessage:
        "Password reset link has been sent (Demo).",
      ),
    );
  }


  //--------------------------------------------------
  // Clear Errors
  //--------------------------------------------------

  void clearError() {
    emit(
      state.copyWith(
        errorMessage: null,
      ),
    );
  }
}
