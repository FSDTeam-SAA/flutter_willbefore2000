import '../repo/auth_repository.dart';
import '../requests/change_password_request.dart';

class ChangePasswordUseCase {
  final AuthRepository _authRepository;

  ChangePasswordUseCase(this._authRepository);

  Future<void> call(ChangePasswordRequest request) {
    return _authRepository.changePassword(request);
  }
}