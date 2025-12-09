import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/infrastructure/dio/dio_client.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';

import '../../presentation/states/auth_state.dart';

class ProfileApi {
  final Dio _dio;
  final Ref ref;

  ProfileApi(this.ref) : _dio = ref.read(dioProvider);

  Future<Map<String, dynamic>> getProfileApi(String userId) async {
    try {
      final authState = ref.read(authProvider).value;
      String? accessToken;

      if (authState is AuthAuthenticated) {
        accessToken = authState.user.accessToken;
      }

      if (accessToken == null) {
        throw 'Unauthorized: Token not found.';
      }

      final response = await _dio.get(
        '/user/$userId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.data['code'] == 200) {
        final data = response.data['data'] ?? {};

        final username = data['username'] ?? '-';
        final email = data['email'];
        final profilePicture = data['profile_picture'];

        return {
          'username': username,
          'email': email,
          'profile_picture': profilePicture,
        };
      }

      throw response.data['message'] ?? 'Failed to fetch alarm.';
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
}
