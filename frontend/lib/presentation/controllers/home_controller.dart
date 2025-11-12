import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:frontend/domain/entities/sensor.dart';
import 'package:frontend/presentation/providers/device_provider.dart';
import 'package:frontend/presentation/states/device_state.dart';

class HomeController extends StateNotifier<Map<String, dynamic>> {
  final Ref ref;
  StreamSubscription<SensorEntity>? _sub;

  HomeController(this.ref) : super({});

  
}
