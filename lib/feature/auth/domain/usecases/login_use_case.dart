import '../models/user_model.dart';
import '../repo/auth_repository.dart';
import '../requests/login_request.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserModel> call(LoginRequest request) async {
    return await repository.login(request);
  }
}
