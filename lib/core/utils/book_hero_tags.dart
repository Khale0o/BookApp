import 'package:bookapp/features/books/domain/book.dart';

String carouselBookHeroTag(Book book) =>
    'carousel-cover-${book.id ?? book.displayTitle}';
String shelfBookHeroTag(Book book, int index) =>
    'shelf-cover-${book.id ?? book.displayTitle}-$index';
