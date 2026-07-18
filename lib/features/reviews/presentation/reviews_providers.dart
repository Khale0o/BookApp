import 'package:bookapp/features/books/presentation/books_providers.dart';
import 'package:bookapp/features/reviews/data/reviews_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reviewsRepositoryProvider = Provider<ReviewsRepository>(
  (ref) => ApiReviewsRepository(ref.watch(apiClientProvider)),
);
