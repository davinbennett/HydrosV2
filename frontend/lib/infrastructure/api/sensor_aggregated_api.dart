import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/infrastructure/dio/dio_client.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';

import '../../presentation/states/auth_state.dart';

class SensorAggregatedApi {
  final Dio _dio;
  final Ref ref;

  SensorAggregatedApi(this.ref) : _dio = ref.read(dioProvider);

  Future<Map<String, dynamic>> getSensorAggregatedApi(
    String devideId,
    bool isToday,
    bool isLastDay,
    bool isThisMonth,
    String startDate,
    String endDate,
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

      final queryParams = {
        'today': isToday.toString(),
        'lastday': isLastDay.toString(),
        'month': isThisMonth.toString(),
      };

      if (startDate.isNotEmpty && endDate.isNotEmpty) {
        queryParams['start-date'] = startDate;
        queryParams['end-date'] = endDate;
      }

      final response = await _dio.get(
        '/sensor-aggregated/$devideId',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.data['code'] == 200) {
        final data = response.data['data'] ?? {};

        final avgTemperature = data['AvgTemperature'] ?? 0.0;
        final avgHumidity = data['AvgHumidity'] ?? 0.0;
        final avgSoil = data['AvgSoilMoisture'] ?? 0.0;

        return {
          'avg_temperature': avgTemperature,
          'avg_humidity': avgHumidity,
          'avg_soil': avgSoil,
        };
      }

      throw response.data['message'] ??
          'Failed to get data environmental averages.';
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
