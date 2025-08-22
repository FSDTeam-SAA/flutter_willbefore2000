import '../repo/auth_repository.dart';
import '../requests/signup_request.dart';
import '../models/user_model.dart';

class SignupUseCase {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  Future<UserModel> call(SignupRequest request) async {
    return await repository.signup(request);
  }
}
