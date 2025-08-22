import '../models/user_model.dart';
import '../requests/login_request.dart';
import '../requests/signup_request.dart';
import '../requests/forgot_password_request.dart';

abstract class AuthRepository {
  Future<UserModel> login(LoginRequest request);
  Future<UserModel> signup(SignupRequest request);
  Future<void> forgotPassword(ForgotPasswordRequest request);
  Future<void> resetPassword(String code, String newPassword);
  Future<void> sendEmailVerification();
  Future<void> updateUserProfile(UserModel user);
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
  Future<void> logout();
}
