import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutx_core/flutx_core.dart';

import '../../../../core/errors/auth_exception.dart';
import '../../domain/requests/login_request.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSource(this._firebaseAuth);

  Future<User> login(LoginRequest request) async {
    DPrint.log("Login Requests -> ${request.email}");
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: request.email,
        password: request.password,
      );

      DPrint.log("Logged in credential : ${userCredential.user?.email}");
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? "Login failed. Please try again.");
    }
  }

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}