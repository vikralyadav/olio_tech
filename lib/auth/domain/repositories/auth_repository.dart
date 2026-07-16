import '../entities/user.dart';

abstract class AuthRepository {
  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<void> register({
    required User user,
    required String password,
  });

  Future<void> logout();

  Future<bool> isLoggedIn();

  Future<User?> getCurrentUser();
}