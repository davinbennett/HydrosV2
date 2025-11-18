
import '../../domain/repositories/pumplog.dart';
import '../../infrastructure/api/pumplog_api.dart';


class PumpLogImpl implements PumplogRepository {
  final PumplogApi api;
  PumpLogImpl({required this.api});

  @override
  Future<Map<String, dynamic>> getQuickActivityImpl(String devideId) {
    return api.getQuickActivityApi(devideId);
  }
}