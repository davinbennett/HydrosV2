import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityPlusClient {
  static Future<List<ConnectivityResult>> checkConnectivity() async {
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();

    return connectivityResult;
  }
}
