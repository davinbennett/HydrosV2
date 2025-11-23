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

  Future<Map<String, dynamic>> getWaterFlowActivityApi(
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
        '/pumplog/water-flow/$devideId',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.data['code'] == 200) {
        final data = response.data['data'] ?? {};

        final totalPump = (data['total_pump'] ?? 0) as int;

        final rawAvg = data['average_duration'];
        final avgDuration =
            rawAvg == null
                ? 0.0
                : double.tryParse(rawAvg.toString())?.toDouble() ?? 0.0;

        final avgDurationFixed = double.parse(avgDuration.toStringAsFixed(2));

        final detail = (data['detail'] ?? []) as List;

        return {
          'total_pump': totalPump,
          'average_duration': avgDurationFixed,
          'detail': detail,
        };
      }

      throw response.data ?? 'Failed to get data water flow activity.';
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw 'Connection timeout. Please try again.';

        case DioExceptionType.connectionError:
          throw 'Unable to connect to the server. Please check your internet connection.';

        case DioExceptionType.badResponse:
          final message = e.response?.data;
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
  
  Future<Map<String, dynamic>> getPumpUsageApi(
    String devideId,
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


      final response = await _dio.get(
        '/pumplog/$devideId/pump-usage',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.data['code'] == 200) {
        final data = response.data['data'] ?? {};

        final pumpUsage = (data['pump_usage'] ?? 0);

        return {
          'pump_usage': pumpUsage,
        };
      }

      throw response.data ?? 'Failed to get data pump usage.';
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw 'Connection timeout. Please try again.';

        case DioExceptionType.connectionError:
          throw 'Unable to connect to the server. Please check your internet connection.';

        case DioExceptionType.badResponse:
          final message = e.response?.data;
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

  Future<Map<String, dynamic>> getLastWateredApi(
    String devideId,
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


      final response = await _dio.get(
        '/pumplog/$devideId/last-watered',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.data['code'] == 200) {
        final data = response.data['data'] ?? {};

        final lastWatered = (data['last_watered'] ?? 0);

        return {
          'last_watered': lastWatered,
        };
      }

      throw response.data ?? 'Failed to get data last watered.';
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw 'Connection timeout. Please try again.';

        case DioExceptionType.connectionError:
          throw 'Unable to connect to the server. Please check your internet connection.';

        case DioExceptionType.badResponse:
          final message = e.response?.data;
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
