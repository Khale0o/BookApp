import 'dart:typed_data';

import 'package:bookapp/core/auth/token_store.dart';
import 'package:bookapp/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({this.statusCode = 200});
  final int statusCode;
  final requests = <RequestOptions>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      '{}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  test('bearer interceptor protects account paths but not login', () async {
    final store = MemoryTokenStore('secret-token');
    final adapter = _RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(BearerTokenInterceptor(store));

    await dio.get<Object?>('/api/Users/Cart');
    await dio.post<Object?>('/api/Auth/Login');

    expect(
      adapter.requests.first.headers['Authorization'],
      'Bearer secret-token',
    );
    expect(adapter.requests.last.headers.containsKey('Authorization'), isFalse);
  });

  test('unauthorized protected response clears the stored token', () async {
    final store = MemoryTokenStore('expired');
    final adapter = _RecordingAdapter(statusCode: 401);
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(BearerTokenInterceptor(store));

    await expectLater(
      dio.get<Object?>('/api/Users/UserInfo'),
      throwsA(isA<DioException>()),
    );
    expect(await store.read(), isNull);
  });
}
