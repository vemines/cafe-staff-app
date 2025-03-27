part of 'exceptions.dart';

Failure handleRepositoryException(Object e) {
  if (e is ServerException) {
    return e.toFailure();
  } else if (e is InvalidCredentialsException) {
    return InvalidCredentialsFailure();
  } else if (e is UnauthenticatedException) {
    return UnauthenticatedFailure();
  } else if (e is TimeoutException) {
    return TimeoutFailure();
  } else if (e is ForbiddenException) {
    return ForbiddenFailure();
  } else {
    return ServerFailure(message: e.toString());
  }
}
