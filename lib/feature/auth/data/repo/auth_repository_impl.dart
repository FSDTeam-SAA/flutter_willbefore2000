import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/user_model.dart';
import '../../domain/repo/auth_repository.dart';
import '../../domain/requests/login_request.dart';
import '../sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserModel> login(LoginRequest request) async {
    final user = await remoteDataSource.login(request);
    return UserModel.fromFirebase(user);
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return remoteDataSource.authStateChanges.map((user) {
      return user != null ? UserModel.fromFirebase(user) : null;
    });
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = AuthRemoteDataSource(FirebaseAuth.instance);
  return AuthRepositoryImpl(remoteDataSource);
});
