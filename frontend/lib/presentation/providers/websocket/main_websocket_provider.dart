import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/websocket/main_websocket.dart';

final websocketManagerProvider = Provider<WebSocketManager>((ref) {
  return WebSocketManager(ref);
});

class WebSocketManager {
  final Ref ref;

  WebSocketManager(this.ref);

  Future<void> init() async => await initWebsocket(ref);
  Future<void> close() async => await closeWebsocket(ref);
}
