import 'package:bookapp/features/profile/domain/account_models.dart';
import 'package:bookapp/features/reviews/domain/book_review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('review parsing preserves backend values defensively', () {
    final review = BookReview.fromJson({
      'firstName': ' Ada ',
      'lastName': 'Reader',
      'ratingValue': '4.5',
      'reviewDate': '2026-07-18T10:00:00Z',
    });

    expect(review.displayName, 'Ada Reader');
    expect(review.ratingValue, 4.5);
    expect(review.reviewDate, isNotNull);
  });

  test('address DTO output contains only documented fields', () {
    const address = UserAddress(
      id: 7,
      addressLine1: 'One Street',
      city: 'Cairo',
      country: 'Egypt',
    );

    expect(address.toAddJson().containsKey('id'), isFalse);
    expect(address.toEditJson()['id'], 7);
    expect(address.oneLine, 'One Street, Cairo, Egypt');
  });

  test('order totals are computed only when price and quantity exist', () {
    final complete = UserOrder.fromJson({
      'id': 1,
      'orderLine': [
        {'bookId': 2, 'quantity': 2, 'price': 3.5},
      ],
    });
    final incomplete = UserOrder.fromJson({
      'id': 2,
      'orderLine': [
        {'bookId': 2, 'quantity': 2},
      ],
    });

    expect(complete.total, 7);
    expect(incomplete.total, isNull);
  });
}
