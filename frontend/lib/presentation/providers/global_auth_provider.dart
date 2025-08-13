import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/presentation/controllers/splash_controller.dart';
import 'package:frontend/presentation/states/global_auth_state.dart';

final globalStateProvider =
    StateNotifierProvider<SplashController, GlobalState>((ref) {
      return SplashController()..checkLogin();
    });
