import 'package:bookapp/core/config/app_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  ApiClient({Dio? dio}) : dio = dio ?? _createDio();
  final Dio dio;

  static Dio _createDio() {
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
