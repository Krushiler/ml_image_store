import 'package:dio/dio.dart';

String createErrorMessage(dynamic e) {
  try {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout';
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout';
        case DioExceptionType.connectionError:
          return 'Connection timeout';
        default:
          return e.response?.data?['message'] ?? e.message ?? 'Something went wrong';
      }
    }
    if (e is Exception) {
      return e.toString();
    }
    return 'Something went wrong';
  } catch (_) {
    return 'Something went wrong';
  }
}
