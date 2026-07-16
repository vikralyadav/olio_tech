
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasourse/auth_local_data_sourse.dart';
import '../models/ user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) {
    return localDataSource.login(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
  }

  @override
  Future<void> logout() {
    return localDataSource.logout();
  }

  @override
  Future<bool> isLoggedIn() {
    return localDataSource.isLoggedIn();
  }

  @override
  Future<User?> getCurrentUser() {
    return localDataSource.getCurrentUser();
  }

  @override
  Future<void> register({
    required User user,
    required String password,
  }) {
    return localDataSource.register(
      user: UserModel(email: user.email),
      password: password,
    );
  }
}