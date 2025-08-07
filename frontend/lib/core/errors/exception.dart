abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

class TimeoutException extends AppException {
  TimeoutException() : super('Permintaan ke server melebihi waktu tunggu.');
}

class NetworkException extends AppException {
  NetworkException() : super('Tidak dapat terhubung ke jaringan.');
}

class NotFoundException extends AppException {
  NotFoundException() : super('Data tidak ditemukan.');
}

class ServerException extends AppException {
  ServerException([super.message = 'Terjadi kesalahan pada server.']);
}

class UnknownException extends AppException {
  UnknownException([super.msg = 'Terjadi kesalahan tidak diketahui.']);
}
