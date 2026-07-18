import 'package:bookapp/core/auth/token_store.dart';
import 'package:bookapp/core/network/api_client.dart';

abstract interface class AuthRepository {
  Future<String> login({required String email, required String password});
  Future<void> signUp(Map<String, Object?> values);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword({
    required String password,
    required String passwordConfirm,
    required String token,
  });
  Future<String?> restoreToken();
  Future<void> logout();
}

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._client, this._store);
  final ApiClient _client;
  final TokenStore _store;

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post<Object?>(
      '/api/Auth/Login',
      data: {'email': email.trim(), 'password': password},
    );
    final token = extractBearerToken(response.data);
    if (token == null) {
      throw const FormatException(
        'The login response did not contain a usable session token.',
      );
    }
    await _store.write(token);
    return token;
  }

  @override
  Future<void> signUp(Map<String, Object?> values) async {
    await _client.dio.post<void>('/api/Auth/SignUp', data: values);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _client.dio.post<void>(
      '/api/Auth/ForgotPassword',
      data: {'email': email.trim()},
    );
  }

  @override
  Future<void> resetPassword({
    required String password,
    required String passwordConfirm,
    required String token,
  }) async {
    await _client.dio.post<void>(
      '/api/Auth/ResetPassword',
      data: {
        'password': password,
        'passwordConfirm': passwordConfirm,
        'token': token.trim(),
      },
    );
  }

  @override
  Future<String?> restoreToken() => _store.read();

  @override
  Future<void> logout() => _store.clear();
}

String? extractBearerToken(Object? data) {
  String? usable(Object? value) {
    if (value is! String) return null;
    final token = value.trim();
    return token.isEmpty ? null : token;
  }

  final direct = usable(data);
  if (direct != null) return direct;
  if (data is Map) {
    // The success schema is undocumented. These keys are parser tolerance only;
    // no response shape is exposed as a product assumption.
    for (final key in const ['token', 'accessToken', 'access_token']) {
      final token = usable(data[key]);
      if (token != null) return token;
    }
    final nested = data['data'];
    if (nested is Map) {
      for (final key in const ['token', 'accessToken', 'access_token']) {
        final token = usable(nested[key]);
        if (token != null) return token;
      }
    }
  }
  return null;
}
