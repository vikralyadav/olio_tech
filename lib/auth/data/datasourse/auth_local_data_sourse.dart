



import '../models/ user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> register({
    required UserModel user,
    required String password,
  });

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<void> logout();

  Future<bool> isLoggedIn();

  Future<UserModel?> getCurrentUser();
}