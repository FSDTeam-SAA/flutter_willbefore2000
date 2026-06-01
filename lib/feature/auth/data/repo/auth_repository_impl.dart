import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smilestreatsapp/feature/auth/domain/requests/change_password_request.dart';

import '../../../../core/services/notification_service.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repo/auth_repository.dart';
import '../../domain/requests/login_request.dart';
import '../../domain/requests/signup_request.dart';
import '../../domain/requests/forgot_password_request.dart';
import '../sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserModel> login(LoginRequest request) async {
    final user = await remoteDataSource.login(request);
    // Get user data from Firestore
    final userModel = await remoteDataSource.getCurrentUser();

    // Trigger FCM token storage after successful login
    await NotificationService().getToken();

    return userModel ?? UserModel.fromFirebase(user);
  }

  @override
  Future<UserModel> signup(SignupRequest request) async {
    return await remoteDataSource.signup(request);
  }

  @override
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    await remoteDataSource.forgotPassword(request);
  }

  @override
  Future<void> changePassword(ChangePasswordRequest request) async {
    await remoteDataSource.changePassword(request);
  }

  @override
  Future<void> resetPassword(String code, String newPassword) async {
    await remoteDataSource.resetPassword(code, newPassword);
  }

  @override
  Future<void> sendEmailVerification() async {
    await remoteDataSource.sendEmailVerification();
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    await remoteDataSource.updateUserProfile(user);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return await remoteDataSource.getCurrentUser();
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return remoteDataSource.authStateChanges.asyncMap((user) async {
      if (user != null) {
        return await remoteDataSource.getCurrentUser();
      }
      return null;
    });
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<void> deleteAccount(String password) async {
    await remoteDataSource.deleteAccount(password);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = AuthRemoteDataSource(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    FirebaseMessaging.instance,
  );
  return AuthRepositoryImpl(remoteDataSource);
});
