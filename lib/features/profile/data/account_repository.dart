import 'package:bookapp/core/errors/app_exception.dart';
import 'package:bookapp/core/network/api_client.dart';
import 'package:bookapp/features/profile/domain/account_models.dart';
import 'package:dio/dio.dart';

abstract interface class AccountRepository {
  Future<UserProfile> getProfile();
  Future<List<UserAddress>> getAddresses();
  Future<void> addAddress(UserAddress address);
  Future<void> editAddress(UserAddress address);
  Future<List<UserOrder>> getOrders();
  Future<void> uploadImage({
    required String filename,
    required List<int> bytes,
    ProgressCallback? onProgress,
  });
}

class ApiAccountRepository implements AccountRepository {
  ApiAccountRepository(this._client);
  final ApiClient _client;

  @override
  Future<UserProfile> getProfile() async {
    final response = await _client.dio.get<Object?>('/api/Users/UserInfo');
    final map = _unwrapMap(response.data);
    return UserProfile.fromJson(map);
  }

  @override
  Future<List<UserAddress>> getAddresses() async {
    final response = await _client.dio.get<Object?>('/api/Users/Address');
    return _parseList(response.data, const [
      'addresses',
      'data',
    ]).map(UserAddress.fromJson).toList(growable: false);
  }

  @override
  Future<void> addAddress(UserAddress address) =>
      _client.dio.post<void>('/api/Users/Address', data: address.toAddJson());

  @override
  Future<void> editAddress(UserAddress address) =>
      _client.dio.put<void>('/api/Users/Address', data: address.toEditJson());

  @override
  Future<List<UserOrder>> getOrders() async {
    final response = await _client.dio.get<Object?>('/api/Users/Orders');
    return _parseList(response.data, const [
      'orders',
      'data',
    ]).map(UserOrder.fromJson).toList(growable: false);
  }

  @override
  Future<void> uploadImage({
    required String filename,
    required List<int> bytes,
    ProgressCallback? onProgress,
  }) => _client.dio.put<void>(
    '/api/Users/editUserImage',
    data: FormData.fromMap({
      'image': MultipartFile.fromBytes(bytes, filename: filename),
    }),
    onSendProgress: onProgress,
  );
}

Map<String, dynamic> _unwrapMap(Object? data) {
  Object? candidate = data;
  if (data is Map && data['data'] is Map) candidate = data['data'];
  if (candidate is! Map) {
    throw const AppException('The account response was not understood.');
  }
  return Map<String, dynamic>.from(candidate);
}

List<Map<String, dynamic>> _parseList(Object? data, List<String> envelopeKeys) {
  Object? candidate = data;
  if (data is Map) {
    for (final key in envelopeKeys) {
      if (data[key] is List) {
        candidate = data[key];
        break;
      }
    }
  }
  if (candidate is! List) {
    throw const AppException('The account list response was not understood.');
  }
  return candidate
      .whereType<Map>()
      .map((value) => Map<String, dynamic>.from(value))
      .toList(growable: false);
}
