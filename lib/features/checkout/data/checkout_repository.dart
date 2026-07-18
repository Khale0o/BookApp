import 'package:bookapp/core/network/api_client.dart';
import 'package:bookapp/features/cart/domain/cart_item.dart';

abstract interface class CheckoutRepository {
  Future<String> createSession(List<CartItem> items);
}

class ApiCheckoutRepository implements CheckoutRepository {
  ApiCheckoutRepository(this._client);
  final ApiClient _client;

  @override
  Future<String> createSession(List<CartItem> items) async {
    final response = await _client.dio.post<Object?>(
      '/api/CheckoutSession',
      data: items.map((item) => item.toCheckoutJson()).toList(growable: false),
    );
    if (response.data is! String || (response.data as String).trim().isEmpty) {
      throw const FormatException('Checkout did not return a usable value.');
    }
    return (response.data as String).trim();
  }
}

Uri? validateCheckoutUri(String value) {
  final uri = Uri.tryParse(value.trim());
  if (uri == null ||
      uri.scheme.toLowerCase() != 'https' ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty) {
    return null;
  }
  return uri;
}
