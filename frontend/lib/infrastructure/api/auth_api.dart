import 'package:dio/dio.dart';
import 'package:frontend/core/errors/exception.dart';
import 'package:frontend/data/models/auth.dart';
import 'package:frontend/infrastructure/dio/dio_client.dart';

class AuthApi {
  final Dio _dio = DioClient.instance;

  // Login email & password
  Future<LoginModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login-email',
        data: {'email': email, 'password': password},
      );

      final data = response.data['data'];
      return LoginModel.fromJson(data);
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw 'Connection timeout. Please try again.';

        case DioExceptionType.connectionError:
          throw 
            'Unable to connect to the server. Please check your internet connection.';

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
  Future<LoginModel> loginWithGoogle({required String idToken}) async {
    try {
      final response = await _dio.post(
        '/auth/continue-google',
        data: {
          'id_token': idToken,
        },
      );

      final data = response.data['data'];
      return LoginModel.fromJson(data);
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

  // Signup email & password
  Future<SignupModel> signupWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/signup-email',
        data: {'email': email, 'password': password},
      );

      final data = response.data['data'];
      return SignupModel.fromJson(data);
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw 'Connection timeout. Please try again.';

        case DioExceptionType.connectionError:
          throw 
            'Unable to connect to the server. Please check your internet connection.';

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

  // Signup Google
  Future<SignupModel> signupWithGoogle({required String idToken}) async {
    try {
      final response = await _dio.post(
        '/auth/continue-google',
        data: {
          'id_token': idToken,
        },
      );

      final data = response.data['data'];
      return SignupModel.fromJson(data);
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw TimeoutException();
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw TimeoutException();
        case DioExceptionType.connectionError:
          throw NetworkException();
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 404) {
            throw NotFoundException();
          }
          throw ServerException(
            e.response?.statusMessage ?? 'Kesalahan respons',
          );
        default:
          throw UnknownException(e.message ?? 'Kesalahan tidak diketahui');
      }
    } catch (_) {
      throw UnknownException();
    }
  }
}