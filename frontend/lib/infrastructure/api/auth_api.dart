import 'package:dio/dio.dart';
import 'package:frontend/data/models/auth.dart';
import 'package:frontend/infrastructure/dio/dio_client.dart';

class AuthApi {
  final Dio _dio = DioClient.instance;

  // Login email & password
  Future<AuthModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login-email',
        data: {'email': email, 'password': password},
      );

      final data = response.data['data'];
      return AuthModel.fromJson(data);
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw 'Connection timeout. Please try again.';

        case DioExceptionType.connectionError:
          throw 'Unable to connect to the server. Please check your internet connection.';

        case DioExceptionType.badResponse:
          final message = e.response?.data['message'];
          if (message is String && message.isNotEmpty) {
            throw message;
          }
          throw 'Server responded with an error.';

        default:
          throw e.message ?? 'An unknown server error occurred.';
      }
    } catch (e) {
      throw 'An unknown error occurred.';
    }
  }

  // Login Google
  Future<AuthModel> loginWithGoogle({required String idToken}) async {
    try {
      final response = await _dio.post(
        '/auth/continue-google',
        data: {'id_token': idToken},
      );

      final data = response.data['data'];
      return AuthModel.fromJson(data);
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw 'Connection timeout. Please try again.';

        case DioExceptionType.connectionError:
          throw 'Unable to connect to the server. Please check your internet connection.';

        case DioExceptionType.badResponse:
          final message = e.response?.data['message'];
          if (message is String && message.isNotEmpty) {
            throw message;
          }
          throw 'Server responded with an error.';

        default:
          throw e.message ?? 'An unknown server error occurred.';
      }
    } catch (e) {
      throw 'An unknown error occurred.';
    }
  }

  // request otp -> dari klik signup (bukan reset password)
  Future<String> requestOtp({required String email, required String isFrom}) async {
    try {
      final response = await _dio.post(
        '/auth/request-otp',
        data: {'email': email, 'is_from': isFrom},
      );

      final message = response.data['data'];
      return message;
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw 'Connection timeout. Please try again.';

        case DioExceptionType.connectionError:
          throw 'Unable to connect to the server. Please check your internet connection.';

        case DioExceptionType.badResponse:
          final message = e.response?.data['message'];
          if (message is String && message.isNotEmpty) {
            throw message;
          }
          throw 'Server responded with an error.';

        default:
          throw e.message ?? 'An unknown Dio error occurred.';
      }
    } catch (e) {
      throw 'An unknown error occurred.';
    }
  }

  // verify OTP
  Future<String> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {'email': email, 'otp': otp},
      );

      final message = response.data['data'];
      return message;
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw 'Connection timeout. Please try again.';

        case DioExceptionType.connectionError:
          throw 'Unable to connect to the server. Please check your internet connection.';

        case DioExceptionType.badResponse:
          final message = e.response?.data['message'];
          if (message is String && message.isNotEmpty) {
            throw message;
          }
          throw 'Server responded with an error.';

        default:
          throw e.message ?? 'An unknown Dio error occurred.';
      }
    } catch (e) {
      throw 'An unknown error occurred.';
    }
  }

  // register with email final
  Future<AuthModel> registerWithEmail({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register-email',
        data: {'username': username, 'email': email, 'password': password},
      );

      final data = response.data['data'];
      return AuthModel.fromJson(data);
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw 'Connection timeout. Please try again.';

        case DioExceptionType.connectionError:
          throw 'Unable to connect to the server. Please check your internet connection.';

        case DioExceptionType.badResponse:
          final message = e.response?.data['message'];
          if (message is String && message.isNotEmpty) {
            throw message;
          }
          throw 'Server responded with an error.';

        default:
          throw e.message ?? 'An unknown server error occurred.';
      }
    } catch (e) {
      throw 'An unknown error occurred.';
    }
  }

  // create new password
  Future<String> newPassword({required String email, required String password}) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {'email': email, 'new_password': password},
      );

      final message = response.data['data'];
      return message;
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw 'Connection timeout. Please try again.';

        case DioExceptionType.connectionError:
          throw 'Unable to connect to the server. Please check your internet connection.';

        case DioExceptionType.badResponse:
          final message = e.response?.data['message'];
          if (message is String && message.isNotEmpty) {
            throw message;
          }
          throw 'Server responded with an error.';

        default:
          throw e.message ?? 'An unknown Dio error occurred.';
      }
    } catch (e) {
      throw 'An unknown error occurred.';
    }
  }
}
