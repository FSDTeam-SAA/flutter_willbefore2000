import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/base/base_state.dart';
import '../../data/repo/auth_repository_impl.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repo/auth_repository.dart';
import '../../domain/requests/login_request.dart';
import '../../domain/usecases/login_use_case.dart';

class AuthState extends BaseState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isInitialized;

  const AuthState({
    super.isLoading = false,
    super.errorMessage,
    this.user,
    this.isAuthenticated = false,
    this.isInitialized = false,
  });

  @override
  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserModel? user,
    bool? isAuthenticated,
    bool? isInitialized,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final loginUseCase = LoginUseCase(authRepository);

  return AuthProvider(loginUseCase, authRepository);
});

class AuthProvider extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final LoginUseCase _loginUseCase;

  AuthProvider(this._loginUseCase, this._authRepository) : super(AuthState()) {
    _initializeAuthState();

    /// [Listen] to auth state changes
    _authRepository.authStateChanges.listen((user) {
      state = state.copyWith(user: user, isAuthenticated: user != null);
    });
  }

  Future<void> _initializeAuthState() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userModel = UserModel.fromFirebase(currentUser);
        state = state.copyWith(
          user: userModel,
          isAuthenticated: true,
          isInitialized: true,
        );
      } else {
        state = state.copyWith(isAuthenticated: false, isInitialized: true);
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isInitialized: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<bool> login(LoginRequest request) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _loginUseCase.call(request);

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.logout();

      state = state.copyWith(
        user: null,
        isAuthenticated: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
