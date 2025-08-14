import '../repo/auth_repository.dart';
import '../requests/login_request.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<void> call(LoginRequest request) async {
    await repository.login(request);
  }
}