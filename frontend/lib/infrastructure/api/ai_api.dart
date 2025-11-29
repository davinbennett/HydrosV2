import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/infrastructure/dio/dio_client.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/states/auth_state.dart';

class AIApi {

  final Dio _dio;
  final Ref ref;

  AIApi(this.ref) : _dio = ref.read(dioProvider);

  Future<Map<String, dynamic>> postAiReportApi(
    String? plantName,
    int? progressPlan,
    int? progressNow,
    String? longitude,
    String? latitude,
    double? temperature,
    double? soil,
    double? humidity,
    int? pumpUsage,
    String? lastWatered,
    String? time
  ) async {
    try {
      final authState = ref.read(authProvider).value;
      String? accessToken;

      if (authState is AuthAuthenticated) {
        accessToken = authState.user.accessToken;
      }

      if (accessToken == null) {
        throw 'Unauthorized: Token not found.';
      }

      final response = await _dio.post(
        '/ai/report',
        data: {
          "plant_name": plantName,
          "progress_plan": progressPlan,
          "progress_now": progressNow,
          "longitude": longitude,
          "latitude": latitude,
          "temperature": temperature,
          "soil": soil,
          "humidity": humidity,
          "pump_usage": pumpUsage,
          "last_watered": lastWatered,
          "datetime": time
        },

        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      if (response.data['code'] == 200) {
        return response.data['data'];
      }

      throw response.data['data'] ?? 'Failed to analyze with AI';
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
