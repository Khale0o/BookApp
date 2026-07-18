import 'package:bookapp/features/books/domain/book.dart';

class CartItem {
  const CartItem({
    required this.bookId,
    this.bookTitle,
    this.bookPrice = 0,
    this.bookImage,
    this.quantity = 0,
    this.bookDescription,
  });

  final int bookId;
  final String? bookTitle;
  final double bookPrice;
  final String? bookImage;
  final int quantity;
  final String? bookDescription;

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    bookId: Book.parseInt(json['bookId']) ?? 0,
    bookTitle: _text(json['bookTitle']),
    bookPrice: Book.parseDouble(json['bookPrice']) ?? 0,
    bookImage: _text(json['bookImage']),
    quantity: Book.parseInt(json['quantity']) ?? 0,
    bookDescription: _text(json['bookDescription']),
  );

  String get displayTitle => bookTitle ?? 'Untitled book';
  String get displayPrice => bookPrice.toStringAsFixed(2);
  double get lineTotal => bookPrice * quantity;

  Map<String, Object?> toCheckoutJson() => {
    'bookId': bookId,
    'bookTitle': bookTitle,
    'bookPrice': bookPrice,
    'bookImage': bookImage,
    'quantity': quantity,
    'bookDescription': bookDescription,
  };

  static String? _text(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }
}
