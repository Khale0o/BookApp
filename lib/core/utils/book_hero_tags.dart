import 'package:bookapp/features/books/domain/book.dart';

String carouselBookHeroTag(Book book) =>
    'carousel-cover-${book.id ?? book.displayTitle}';
String shelfBookHeroTag(Book book, int index) =>
    'shelf-cover-${book.id ?? book.displayTitle}-$index';
String catalogBookHeroTag(Book book) =>
    'catalog-cover-${book.id ?? book.displayTitle}';
String relatedBookHeroTag(Book book) =>
    'related-cover-${book.id ?? book.displayTitle}';
