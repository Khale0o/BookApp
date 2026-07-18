import 'package:dio/dio.dart';

String mapApiFailure(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status == 400) return 'Please check the information and try again.';
    if (status == 401) {
      return 'Your session is no longer valid. Please sign in.';
    }
    if (status == 403) return 'This account cannot perform that action.';
    if (status == 404) return 'The requested information could not be found.';
    if (status == 409) {
      return 'That change conflicts with the current account state.';
    }
    if (status != null && status >= 500) {
      return 'The bookstore is having trouble. Please try again shortly.';
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return 'The bookstore could not be reached. Check your connection.';
      default:
        break;
    }
  }
  return 'Something went wrong. Please try again.';
}
