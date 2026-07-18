import 'package:bookapp/features/books/presentation/books_providers.dart';
import 'package:bookapp/features/reviews/data/reviews_repository.dart';
import 'package:bookapp/features/reviews/domain/book_review.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reviewsRepositoryProvider = Provider<ReviewsRepository>(
  (ref) => ApiReviewsRepository(ref.watch(apiClientProvider)),
);

typedef ReviewPageRequest = ({int bookId, int page});

final reviewPageProvider = FutureProvider.autoDispose
    .family<List<BookReview>, ReviewPageRequest>((ref, request) {
      return ref
          .watch(reviewsRepositoryProvider)
          .getReviews(request.bookId, pageNumber: request.page);
    });
