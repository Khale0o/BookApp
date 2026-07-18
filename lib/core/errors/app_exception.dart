class AppException implements Exception {
  const AppException(this.message);
  final String message;
  @override
  String toString() => message;
}

class BookNotFoundException extends AppException {
  const BookNotFoundException() : super('This book could not be found.');
}
