import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/infrastructure/dio/dio_client.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/states/auth_state.dart';

class NotificationApi {
  final Dio _dio;
  final Ref ref;

  NotificationApi(this.ref) : _dio = ref.read(dioProvider);

  Future getMyNotificationsApi() async {
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
        '/notifications',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.data['code'] == 200) {
        return response.data['data'];
      }

      throw response.data['data'] ?? 'Failed to load notifications.';
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<String> readNotificationApi(int? id) async {
    try {
      final authState = ref.read(authProvider).value;
      String? accessToken;

      if (authState is AuthAuthenticated) {
        accessToken = authState.user.accessToken;
      }

      if (accessToken == null) {
        throw 'Unauthorized: Token not found.';
      }

      final response = await _dio.patch(
        '/notifications/$id/read',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.data['code'] == 200) {
        return response.data['data'];
      }

      throw response.data['data'] ?? 'Failed to read notification.';
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  Future<String> deleteNotificationApi(int? id) async {
    try {
      final authState = ref.read(authProvider).value;
      String? accessToken;

      if (authState is AuthAuthenticated) {
        accessToken = authState.user.accessToken;
      }

      if (accessToken == null) {
        throw 'Unauthorized: Token not found.';
      }

      final response = await _dio.delete(
        '/notifications/$id',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.data['code'] == 200) {
        return response.data['data'];
      }

      throw response.data['data'] ?? 'Failed to delete notification.';
    } on DioException catch (e) {
      return _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please try again.';

      case DioExceptionType.connectionError:
        return 'Unable to connect to the server. Please check your internet connection.';

      case DioExceptionType.badResponse:
        final message = e.response?.data['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
        return 'Server responded with an error.';

      default:
        return e.message ?? 'An unknown server error occurred.';
    }
  }
}
