import 'package:bookapp/core/errors/app_exception.dart';
import 'package:bookapp/core/network/api_client.dart';
import 'package:bookapp/features/reviews/domain/book_review.dart';

abstract interface class ReviewsRepository {
  Future<List<BookReview>> getReviews(
    int bookId, {
    int pageNumber = 1,
    int pageSize = 6,
  });
}

class ApiReviewsRepository implements ReviewsRepository {
  ApiReviewsRepository(this._client);
  final ApiClient _client;

  @override
  Future<List<BookReview>> getReviews(
    int bookId, {
    int pageNumber = 1,
    int pageSize = 6,
  }) async {
    final response = await _client.dio.get<Object?>(
      '/api/Books/Reviews/$bookId',
      queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
    );
    if (response.data is! List) {
      throw const AppException('The reviews response was not understood.');
    }
    return (response.data as List)
        .whereType<Map>()
        .map((item) => BookReview.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }
}
