class Book {
  const Book({
    this.id,
    this.bookTitle,
    this.authorName,
    this.categoryName,
    this.bookPrice = 0,
    this.bookImage,
    this.bookDescription,
    this.quantityInStock,
    this.publicationYear,
  });

  final int? id;
  final String? bookTitle;
  final String? authorName;
  final String? categoryName;
  final double bookPrice;
  final String? bookImage;
  final String? bookDescription;
  final int? quantityInStock;
  final int? publicationYear;

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: parseInt(json['id']),
    bookTitle: _text(json['bookTitle']),
    authorName: _text(json['authorName']),
    categoryName: _text(json['categoryName']),
    bookPrice: parseDouble(json['bookPrice']) ?? 0,
    bookImage: _text(json['bookImage']),
    bookDescription: _text(json['bookDescription']),
    quantityInStock: parseInt(json['quantityInStock']),
    publicationYear: parseInt(json['publicationYear']),
  );

  static String? _text(Object? value) {
    if (value is! String) return null;
    final result = value.trim();
    return result.isEmpty ? null : result;
  }

  static int? parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return num.tryParse(value.trim())?.toInt();
    return null;
  }

  static double? parseDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  String get displayTitle => bookTitle ?? 'Untitled book';
  String get displayAuthor => authorName ?? 'Author unavailable';
  String get displayCategory => categoryName ?? 'Uncategorized';
  String get displayPrice => bookPrice.toStringAsFixed(2);
  bool get isInStock => (quantityInStock ?? 0) > 0;
}
