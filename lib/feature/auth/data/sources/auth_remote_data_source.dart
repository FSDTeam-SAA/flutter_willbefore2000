import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutx_core/flutx_core.dart';

import '../../../../core/errors/auth_exception.dart';
import '../../domain/requests/change_password_request.dart';
import '../../domain/requests/login_request.dart';
import '../../domain/requests/signup_request.dart';
import '../../domain/requests/forgot_password_request.dart';
import '../../domain/models/user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  AuthRemoteDataSource(this._firebaseAuth, this._firestore, this._messaging);

  Future<User> login(LoginRequest request) async {
    DPrint.log("Login Requests -> ${request.email}");
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: request.email,
        password: request.password,
      );

      final user = userCredential.user!;

      // Check if email is verified
      if (!user.emailVerified) {
        await _firebaseAuth.signOut();
        throw AuthException('email-not-verified');
      }

      DPrint.log("user credential : $userCredential");

      DPrint.log("Logged in credential : ${userCredential.user?.email}");
      return user;
    } on FirebaseAuthException catch (e) {
      DPrint.error("Login error : $e");
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException("Login failed. Please try again.");
    }
  }

  Future<UserModel> signup(SignupRequest request) async {
    DPrint.log("Signup Request -> ${request.email}");
    try {
      // Create user with email and password
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: request.email,
        password: request.password,
      );

      final user = userCredential.user!;

      // Update display name
      await user.updateDisplayName(request.name);

      // Get FCM token
      String? fcmToken;
      try {
        fcmToken = await _messaging.getToken();
      } catch (e) {
        DPrint.log("Failed to get FCM token: $e");
      }

      // Create user document in Firestore
      final userModel = UserModel(
        uid: user.uid,
        email: user.email,
        displayName: request.name,
        phoneNumber: request.phoneNumber,
        fcmToken: fcmToken,
        role: 'user',
        createdAt: DateTime.now(),
        isEmailVerified: user.emailVerified,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toFirestore());

      // Send email verification
      await user.sendEmailVerification();

      // Sign out the user immediately so they must login after verification
      await _firebaseAuth.signOut();

      DPrint.log("User created successfully: ${user.email}");
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException("Signup failed. Please try again.");
    }
  }

  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: request.email);
      DPrint.log("Password reset email sent to: ${request.email}");
    } on FirebaseAuthException catch (e) {
      DPrint.error("Forgot password error: $e");
      throw AuthException(_getAuthErrorMessage(e.code));
    }
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw AuthException('User not authenticated');
      }

      if (user.email == null) {
        throw AuthException('User email not found');
      }

      // First, re-authenticate the user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: request.currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Then update to new password
      await user.updatePassword(request.newPassword);

      DPrint.log("Password updated successfully for user: ${user.email}");
    } on FirebaseAuthException catch (e) {
      DPrint.error("Change password error: $e");
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      DPrint.error("Change password general error: $e");
      throw AuthException("Failed to change password. Please try again.");
    }
  }

  Future<void> resetPassword(String code, String newPassword) async {
    try {
      await _firebaseAuth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    }
  }

  Future<void> updateUserProfile(UserModel userModel) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Update Firebase Auth profile
        await user.updateDisplayName(userModel.displayName);
        if (userModel.photoURL != null) {
          await user.updatePhotoURL(userModel.photoURL);
        }

        // Update Firestore document
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update(userModel.toFirestore());
      }
    } catch (e) {
      throw AuthException("Failed to update profile. Please try again.");
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Force reload to get latest email verification status
        await user.reload();
        final updatedUser = _firebaseAuth.currentUser!;

        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final userModel = UserModel.fromFirestore(doc);

          // Sync email verification status if it changed
          if (userModel.isEmailVerified != updatedUser.emailVerified) {
            final syncedUserModel = userModel.copyWith(
              isEmailVerified: updatedUser.emailVerified,
            );
            await _firestore.collection('users').doc(user.uid).update({
              'isEmailVerified': updatedUser.emailVerified,
            });
            return syncedUserModel;
          }

          return userModel;
        } else {
          // Create user document if it doesn't exist
          final userModel = UserModel.fromFirebase(updatedUser);
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(userModel.toFirestore());
          return userModel;
        }
      }
      return null;
    } catch (e) {
      DPrint.log("Error getting current user: $e");
      return null;
    }
  }

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  String _getAuthErrorMessage(String code) {
    DPrint.info("Auth Error Message code : $code");
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-credential':
        return 'The provided credential is invalid.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'email-not-verified':
        return 'Your email address is not verified. Please check your inbox for a verification link.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
