
import '../models/user_model.dart';
import '../requests/login_request.dart';

abstract class AuthRepository {
  Future<UserModel> login(LoginRequest request);
  Stream<UserModel?> get authStateChanges;
  Future<void> logout();
}