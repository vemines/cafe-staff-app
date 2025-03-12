// --- FILE: lib/core/errors/dio_exception_handle.dart ---
part of 'exceptions.dart';

Never handleDioException(DioException e, StackTrace s, String at) {
  if (e.response != null) {
    final statusCode = e.response!.statusCode;
    final statusMessage = e.response!.statusMessage;

    switch (statusCode) {
      case 400:
        throw ServerException(
          message: statusMessage ?? 'Bad Request',
          statusCode: statusCode,
          stackTrace: s,
        );
      case 401:
        throw InvalidCredentialsException();
      case 403:
        throw ForbiddenException();
      case 404:
        throw ServerException(
          message: statusMessage ?? 'Not Found',
          statusCode: statusCode,
          stackTrace: s,
        );
      case 409:
        throw ServerException(
          message: statusMessage ?? 'Conflict',
          statusCode: statusCode,
          stackTrace: s,
        );
      case 500:
        throw ServerException(
          message: statusMessage ?? 'Internal Server Error',
          statusCode: statusCode,
          stackTrace: s,
        );
      default:
        throw ServerException(
          message: statusMessage ?? 'Server error',
          statusCode: statusCode,
          stackTrace: s,
        );
    }
  } else {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      throw TimeoutException();
    }
  }
  throw ServerException(message: 'Error at: $at: ${e.message}');
}
