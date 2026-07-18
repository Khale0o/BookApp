import 'package:bookapp/features/cart/data/cart_repository.dart';
import 'package:bookapp/features/cart/presentation/cart_controller.dart';
import 'package:bookapp/features/checkout/data/checkout_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cart parses numeric strings and computes only item subtotal', () {
    final items = parseCart([
      {
        'bookId': '3',
        'bookTitle': 'A Book',
        'bookPrice': '4.50',
        'quantity': '2',
      },
    ]);
    final state = CartState(items: items);

    expect(items.single.bookId, 3);
    expect(items.single.quantity, 2);
    expect(state.subtotal, 9);
  });

  test('cart accepts defensive list envelopes but rejects unknown bodies', () {
    expect(parseCart({'items': <Object>[]}), isEmpty);
    expect(() => parseCart({'message': 'ok'}), throwsException);
  });

  test('checkout opens only strict HTTPS destinations', () {
    expect(
      validateCheckoutUri('https://payments.example/session/1'),
      isNotNull,
    );
    expect(validateCheckoutUri('http://payments.example/session/1'), isNull);
    expect(validateCheckoutUri('javascript:alert(1)'), isNull);
    expect(validateCheckoutUri('not a url'), isNull);
    expect(validateCheckoutUri('https://user:pass@example.com'), isNull);
  });
}
