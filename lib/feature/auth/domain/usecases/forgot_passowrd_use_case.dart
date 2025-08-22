import '../repo/auth_repository.dart';
import '../requests/forgot_password_request.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  Future<void> call(ForgotPasswordRequest request) async {
    await repository.forgotPassword(request);
  }
}
