import 'package:flutter_riverpod/legacy.dart';
import 'package:smilestreats/core/services/storage_service.dart';
import 'package:smilestreats/feature/auth/domain/usecases/change_password_use_case.dart';

import '../../../../core/base/base_state.dart';
import '../../../../core/errors/auth_exception.dart';
import '../../data/repo/auth_repository_impl.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repo/auth_repository.dart';
import '../../domain/requests/change_password_request.dart';
import '../../domain/requests/forgot_password_request.dart';
import '../../domain/requests/login_request.dart';
import '../../domain/requests/signup_request.dart';
import '../../domain/usecases/forgot_passowrd_use_case.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/signup_use_case.dart';

class AuthState extends BaseState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isInitialized;
  final String? loginError; // Specific error for login
  final String? signupError; // Specific error for signup
  final String? forgotPasswordError; // Specific error for forgot password
  final String? changePasswordError;

  const AuthState({
    super.isLoading = false,
    super.errorMessage,
    this.loginError = '',
    this.signupError = '',
    this.forgotPasswordError = '',
    this.changePasswordError = '',
    this.user,
    this.isAuthenticated = false,
    this.isInitialized = false,
  });

  @override
  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? loginError,
    String? signupError,
    String? forgotPasswordError,
    String? changePasswordError,
    UserModel? user,
    bool? isAuthenticated,
    bool? isInitialized,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      loginError: loginError ?? this.loginError,
      signupError: signupError ?? this.signupError,
      forgotPasswordError: forgotPasswordError ?? this.forgotPasswordError,
      changePasswordError: changePasswordError ?? this.changePasswordError,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final loginUseCase = LoginUseCase(authRepository);
  final signupUseCase = SignupUseCase(authRepository);
  final forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
  final storageService = StorageService();
  final changePasswordUseCase = ChangePasswordUseCase(authRepository);

  return AuthProvider(
    loginUseCase,
    signupUseCase,
    forgotPasswordUseCase,
    authRepository,
    storageService,
    changePasswordUseCase,
  );
});

class AuthProvider extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final LoginUseCase _loginUseCase;
  final SignupUseCase _signupUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final StorageService storageService;
  final ChangePasswordUseCase _changePasswordUseCase;

  AuthProvider(
    this._loginUseCase,
    this._signupUseCase,
    this._forgotPasswordUseCase,
    this._authRepository,
    this.storageService,
    this._changePasswordUseCase,
  ) : super(const AuthState()) {
    _initializeAuthState();

    /// [Listen] to auth state changes
    _authRepository.authStateChanges.listen((user) {
      state = state.copyWith(
        user: user,
        isAuthenticated: user != null,
        isInitialized: true,
      );
    });
  }

  Future<void> _initializeAuthState() async {
    try {
      final currentUser = await _authRepository.getCurrentUser();

      // Check for email verification if user exists
      if (currentUser != null && !currentUser.isEmailVerified) {
        await _authRepository.logout();
        state = state.copyWith(
          user: null,
          isAuthenticated: false,
          isInitialized: true,
          loginError:
              'Email not verified. Please verify your email before accessing the app.',
        );
        return;
      }

      state = state.copyWith(
        user: currentUser,
        isAuthenticated: currentUser != null,
        isInitialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isInitialized: true,
        loginError: e.toString(), // Use loginError for initialization errors
      );
    }
  }

  Future<bool> login(LoginRequest request) async {
    state = state.copyWith(isLoading: true, loginError: "");
    try {
      await _loginUseCase.call(request);
      state = state.copyWith(isLoading: false, loginError: "");
      return true;
    } catch (e) {
      String message = e.toString();
      if (e is AuthException) {
        message = e.message;
      }
      state = state.copyWith(isLoading: false, loginError: message);
      return false;
    }
  }

  Future<bool> signup(SignupRequest request) async {
    state = state.copyWith(isLoading: true, signupError: "");
    try {
      await _signupUseCase.call(request);
      state = state.copyWith(isLoading: false, signupError: "");
      return true;
    } catch (e) {
      String message = e.toString();
      if (e is AuthException) {
        message = e.message;
      }
      state = state.copyWith(isLoading: false, signupError: message);
      return false;
    }
  }

  Future<bool> forgotPassword(ForgotPasswordRequest request) async {
    state = state.copyWith(isLoading: true, forgotPasswordError: "");
    try {
      await _forgotPasswordUseCase.call(request);
      state = state.copyWith(isLoading: false, forgotPasswordError: "");
      return true;
    } catch (e) {
      String message = e.toString();
      if (e is AuthException) {
        message = e.message;
      }
      state = state.copyWith(isLoading: false, forgotPasswordError: message);
      return false;
    }
  }

  Future<bool> changePassword(ChangePasswordRequest request) async {
    state = state.copyWith(isLoading: true, changePasswordError: "");
    try {
      await _changePasswordUseCase.call(request);
      state = state.copyWith(isLoading: false, changePasswordError: "");
      return true;
    } catch (e) {
      String message = e.toString();
      if (e is AuthException) {
        message = e.message;
      }
      state = state.copyWith(isLoading: false, changePasswordError: message);
      return false;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authRepository.sendEmailVerification();
    } catch (e) {
      state = state.copyWith(
        loginError: e.toString(),
      ); // Use loginError or add a specific field
    }
  }

  Future<bool> updateProfile(UserModel user) async {
    state = state.copyWith(isLoading: true, loginError: "");
    try {
      await _authRepository.updateUserProfile(user);
      state = state.copyWith(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        loginError: e.toString(),
      ); // Use loginError or add a specific field
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> getCurretnUser() async {
    state = state.copyWith(isLoading: true);

    try {
      final user = await _authRepository.getCurrentUser();
      state = state.copyWith(user: user);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authRepository.logout();
      state = const AuthState(
        user: null,
        isAuthenticated: false,
        isLoading: false,
        isInitialized: true,
        loginError: '',
        signupError: '',
        forgotPasswordError: '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, loginError: e.toString());
    }
  }
}
