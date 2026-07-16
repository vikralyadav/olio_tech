import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<void> call({
    required User user,
    required String password,
  }) {
    return repository.register(
      user: user,
      password: password,
    );
  }
}