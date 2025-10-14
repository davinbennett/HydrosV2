abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

class TimeoutException extends AppException {
  TimeoutException() : super('Request Timeout.');
}

class NetworkException extends AppException {
  NetworkException([super.message = 'Unable to connect to network.']);
}

class NotFoundException extends AppException {
  NotFoundException() : super('Data not found.');
}

class ServerException extends AppException {
  ServerException([super.message = 'An error occurred on the server.']);
}

class UnknownException extends AppException {
  UnknownException([super.msg = 'An unknown error occurred.']);
}
