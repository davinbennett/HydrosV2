import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/infrastructure/dio/dio_client.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';

import '../../presentation/states/auth_state.dart';

class PumplogApi {
  final Dio _dio;
  final Ref ref;

  PumplogApi(this.ref) : _dio = ref.read(dioProvider);

  Future<Map<String, dynamic>> getQuickActivityApi(String devideId) async {
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
        '/pumplog/$devideId/quick-activity?today=true',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.data['code'] == 200) {
        final data = response.data['data'] ?? {};

        final lastPumped = data['last_pumped'];
        final soilMin = data['soil_min'];
        final soilMax = data['soil_max'];

        return {
          'last_pumped': lastPumped,
          'soil_min': soilMin,
          'soil_max': soilMax,
        };
      }

      throw response.data['message'] ?? 'Failed to get data quick activity.';
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
