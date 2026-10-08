import 'package:dio/dio.dart';

String friendlyError(Object e) {
  if (e is DioException) {
    if (e.response?.statusCode == 401) return 'Session expired, please log in again.';
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Request timed out.';
      case DioExceptionType.connectionError:
        return 'You appear to be offline.';
      default:
        return 'Something went wrong.';
    }
  }
  return e.toString().replaceFirst('Exception: ', '');
}