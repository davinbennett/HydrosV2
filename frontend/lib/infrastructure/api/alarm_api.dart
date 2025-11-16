import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/infrastructure/dio/dio_client.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';

import '../../presentation/states/auth_state.dart';

class AlarmApi {
  final Dio _dio;
  final Ref ref;

  AlarmApi(this.ref) : _dio = ref.read(dioProvider);

  Future<Map<String, dynamic>> fetchAlarmApi(String devideId) async {
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
        '/alarm/$devideId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.data['code'] == 200) {
        final data = response.data['data'] ?? {};

        final nextAlarm = data['next_alarm'] ?? '-';
        final listAlarmRaw = data['list_alarm'];

        List<Map<String, dynamic>> listAlarm = [];

        if (listAlarmRaw is List) {
          listAlarm =
              listAlarmRaw
                  .whereType<Map<String, dynamic>>()
                  .map(
                    (e) => {
                      'id': e['id'] ?? 0,
                      'schedule_time': e['schedule_time'] ?? '',
                      'is_enabled': e['is_enabled'] ?? false,
                      'duration_on': e['duration_on'] ?? 0,
                      'repeat_type': e['repeat_type'] ?? 1,
                    },
                  )
                  .toList();
        }

        return {'next_alarm': nextAlarm, 'list_alarm': listAlarm};
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

  Future<int> postAlarmApi(
    String? deviceId,
    String? scheduleTime,
    int? durationOn,
    int? repeatType,
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
        '/alarm',
        data: {
          "device_id": deviceId, 
          "schedule_time": scheduleTime,
          "duration_on": durationOn,
          "repeat_type": repeatType,
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.data['code'] == 200) {
        return response.data['data']['alarm_id'];
      }

      throw response.data['data'] ?? 'Failed to add alarm.';
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

  Future<String> updateEnableAlarmApi(
    int? alarmId,
    String? deviceId,
    bool? isEnabled,
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

      final response = await _dio.patch(
        '/alarm/$alarmId/control-enabled',
        data: {
          "device_id": deviceId, 
          "is_enabled": isEnabled,
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.data['code'] == 200) {
        return response.data['data'];
      }

      throw response.data['data'] ?? 'Failed to update switch alarm.';
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

  Future<String> deleteAlarmApi(
    int? alarmId,
    String? deviceId,
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

      final response = await _dio.delete(
        '/alarm/$alarmId',
        data: {
          "device_id": deviceId, 
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.data['code'] == 200) {
        return response.data['data'];
      }

      throw response.data['data'] ?? 'Failed to update switch alarm.';
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

  Future<String> updateAlarmApi(
    int? alarmId,
    String? deviceId,
    String? scheduleTime,
    int? durationOn,
    int? repeatType,
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

      final response = await _dio.patch(
        '/alarm/$alarmId',
        data: {
          "device_id": deviceId,
          "schedule_time": scheduleTime,
          "duration_on": durationOn,
          "repeat_type": repeatType,
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.data['code'] == 200) {
        return response.data['data'];
      }

      throw response.data['data'] ?? 'Failed to add alarm.';
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
