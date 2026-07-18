import 'package:bookapp/core/config/app_config.dart';
import 'package:bookapp/core/auth/token_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  ApiClient({Dio? dio, TokenStore? tokenStore})
    : dio = dio ?? _createDio(tokenStore: tokenStore);
  final Dio dio;

  static Dio _createDio({TokenStore? tokenStore}) {
    final client = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
        headers: const {'Accept': 'application/json'},
      ),
    );
    if (tokenStore != null) {
      client.interceptors.add(BearerTokenInterceptor(tokenStore));
    }
    if (kDebugMode) {
      client.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          requestBody: false,
          responseBody: false,
        ),
      );
    }
    return client;
  }
}

class BearerTokenInterceptor extends Interceptor {
  BearerTokenInterceptor(this._store);
  final TokenStore _store;

  static const _publicAuthPaths = {
    '/api/Auth/Login',
    '/api/Auth/SignUp',
    '/api/Auth/ForgotPassword',
    '/api/Auth/ResetPassword',
  };

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_publicAuthPaths.contains(options.path)) {
      final token = await _store.read();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !_publicAuthPaths.contains(err.requestOptions.path)) {
      await _store.clear();
    }
    handler.next(err);
  }
}
