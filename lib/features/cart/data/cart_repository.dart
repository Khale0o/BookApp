import 'package:bookapp/core/errors/app_exception.dart';
import 'package:bookapp/core/network/api_client.dart';
import 'package:bookapp/features/cart/domain/cart_item.dart';

abstract interface class CartRepository {
  Future<List<CartItem>> getCart();
  Future<void> addBook(int bookId);
  Future<void> removeBook(int bookId);
}

class ApiCartRepository implements CartRepository {
  ApiCartRepository(this._client);
  final ApiClient _client;

  @override
  Future<List<CartItem>> getCart() async {
    final response = await _client.dio.get<Object?>('/api/Users/Cart');
    return parseCart(response.data);
  }

  @override
  Future<void> addBook(int bookId) =>
      _client.dio.post<void>('/api/Users/Cart/$bookId');

  @override
  Future<void> removeBook(int bookId) =>
      _client.dio.delete<void>('/api/Users/Cart/$bookId');
}

List<CartItem> parseCart(Object? data) {
  Object? candidate = data;
  if (data is Map) {
    candidate = data['cart'] ?? data['items'] ?? data['data'];
  }
  if (candidate is! List) {
    throw const AppException('The cart response was not understood.');
  }
  return candidate
      .whereType<Map>()
      .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
      .where((item) => item.bookId > 0)
      .toList(growable: false);
}
