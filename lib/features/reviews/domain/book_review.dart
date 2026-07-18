class BookReview {
  const BookReview({
    this.comment,
    this.firstName,
    this.lastName,
    this.ratingValue,
    this.userImageUrl,
    this.reviewDate,
  });

  final String? comment;
  final String? firstName;
  final String? lastName;
  final double? ratingValue;
  final String? userImageUrl;
  final DateTime? reviewDate;

  factory BookReview.fromJson(Map<String, dynamic> json) => BookReview(
    comment: _text(json['comment']),
    firstName: _text(json['firstName']),
    lastName: _text(json['lastName']),
    ratingValue: _double(json['ratingValue']),
    userImageUrl: _text(json['userImageUrl']),
    reviewDate: DateTime.tryParse(_text(json['reviewDate']) ?? ''),
  );

  String get displayName {
    final name = [firstName, lastName].whereType<String>().join(' ').trim();
    return name.isEmpty ? 'Reader' : name;
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  static double? _double(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }
}
