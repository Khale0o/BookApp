import 'package:flutter/foundation.dart';

enum AuthStatus { restoring, unauthenticated, authenticated }

@immutable
class AuthState {
  const AuthState({
    this.status = AuthStatus.restoring,
    this.isBusy = false,
    this.message,
    this.errorMessage,
  });

  final AuthStatus status;
  final bool isBusy;
  final String? message;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    bool? isBusy,
    Object? message = _unchanged,
    Object? errorMessage = _unchanged,
  }) => AuthState(
    status: status ?? this.status,
    isBusy: isBusy ?? this.isBusy,
    message: identical(message, _unchanged) ? this.message : message as String?,
    errorMessage: identical(errorMessage, _unchanged)
        ? this.errorMessage
        : errorMessage as String?,
  );
}

const _unchanged = Object();
