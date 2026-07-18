import 'package:bookapp/features/auth/data/auth_repository.dart';
import 'package:bookapp/features/auth/domain/auth_state.dart';
import 'package:bookapp/features/auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.token});
  String? token;

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    token = 'signed-token';
    return token!;
  }

  @override
  Future<void> logout() async => token = null;

  @override
  Future<void> resetPassword({
    required String password,
    required String passwordConfirm,
    required String token,
  }) async {}

  @override
  Future<String?> restoreToken() async => token;

  @override
  Future<void> signUp(Map<String, Object?> values) async {}
}

void main() {
  test(
    'token extraction tolerates documented gap without accepting empty data',
    () {
      expect(extractBearerToken(' direct-token '), 'direct-token');
      expect(extractBearerToken({'token': 'map-token'}), 'map-token');
      expect(
        extractBearerToken({
          'data': {'accessToken': 'nested-token'},
        }),
        'nested-token',
      );
      expect(extractBearerToken({'token': '  '}), isNull);
      expect(extractBearerToken({'unrelated': 'value'}), isNull);
    },
  );

  test('session restores and logout clears authenticated state', () async {
    final repository = _FakeAuthRepository(token: 'restored');
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    container.read(authControllerProvider);
    await Future<void>.delayed(Duration.zero);
    expect(
      container.read(authControllerProvider).status,
      AuthStatus.authenticated,
    );

    await container.read(authControllerProvider.notifier).logout();
    expect(
      container.read(authControllerProvider).status,
      AuthStatus.unauthenticated,
    );
    expect(repository.token, isNull);
  });
}
