import 'package:bookapp/features/books/domain/book.dart';

String carouselBookHeroTag(Book book) =>
    'carousel-cover-${book.id ?? book.displayTitle}';
String shelfBookHeroTag(Book book, int index, {String context = 'curated'}) =>
    'shelf-cover-$context-${book.id ?? book.displayTitle}-$index';
String catalogBookHeroTag(Book book) =>
    'catalog-cover-${book.id ?? book.displayTitle}';
String relatedBookHeroTag(Book book) =>
    'related-cover-${book.id ?? book.displayTitle}';
