import 'package:bookapp/core/errors/api_failure_mapper.dart';
import 'package:bookapp/features/auth/data/auth_repository.dart';
import 'package:bookapp/features/auth/domain/auth_state.dart';
import 'package:bookapp/features/books/presentation/books_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ApiAuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStoreProvider),
  ),
);

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    Future<void>.microtask(restore);
    return const AuthState();
  }

  Future<void> restore() async {
    try {
      final token = await _repository.restoreToken();
      state = AuthState(
        status: token == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
      );
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isBusy: true, errorMessage: null, message: null);
    try {
      await _repository.login(email: email, password: password);
      state = const AuthState(status: AuthStatus.authenticated);
      return true;
    } catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: error is FormatException
            ? 'The server did not return a usable session. Please contact support.'
            : mapApiFailure(error),
      );
      return false;
    }
  }

  Future<bool> signUp(Map<String, Object?> values) async {
    state = state.copyWith(isBusy: true, errorMessage: null, message: null);
    try {
      await _repository.signUp(values);
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        message: 'Account created. Sign in to continue.',
      );
      return true;
    } catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: mapApiFailure(error),
      );
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isBusy: true, errorMessage: null, message: null);
    try {
      await _repository.forgotPassword(email);
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        message:
            'If the account exists, reset instructions have been requested.',
      );
      return true;
    } catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: mapApiFailure(error),
      );
      return false;
    }
  }

  Future<bool> resetPassword({
    required String password,
    required String passwordConfirm,
    required String token,
  }) async {
    state = state.copyWith(isBusy: true, errorMessage: null, message: null);
    try {
      await _repository.resetPassword(
        password: password,
        passwordConfirm: passwordConfirm,
        token: token,
      );
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        message: 'Password updated. Sign in with the new password.',
      );
      return true;
    } catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: mapApiFailure(error),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
