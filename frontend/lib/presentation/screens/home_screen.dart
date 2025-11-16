import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/themes/element_size.dart';
import 'package:frontend/core/themes/radius_size.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/themes/font_weight.dart';
import 'package:frontend/core/utils/logger.dart';
import 'package:frontend/core/utils/media_query_helper.dart';
import 'package:frontend/infrastructure/local/secure_storage.dart';
import 'package:frontend/presentation/providers/device_provider.dart';
import 'package:frontend/presentation/providers/sensor_provider.dart';
import 'package:frontend/presentation/states/device_state.dart';
import 'package:frontend/presentation/widgets/global/app_bar.dart';
import 'package:frontend/presentation/widgets/global/button.dart';
import 'package:frontend/presentation/widgets/home/pie_chart.dart';
import 'package:frontend/presentation/widgets/home/status_indicator.dart';

import '../../core/utils/parse_to_double.dart';
import '../../infrastructure/websocket/main_websocket.dart';
import '../controllers/home_controller.dart';
import '../providers/websocket/device_status_provider.dart';
import '../providers/websocket/main_websocket_provider.dart';
import '../providers/websocket/pump_status_provider.dart';
import '../providers/websocket/sensor_provider.dart';
import '../widgets/home/bottomsheet/add_plant.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomeScreen> {
  Future<void> _logSecureStorage() async {
    final token = await SecureStorage.getAccessToken();
    final userId = await SecureStorage.getUserId();
    final deviceId = await SecureStorage.getDeviceId();
    final pairedAt = await SecureStorage.getPairedAt();

    logger.i('🔐 Access Token: $token');
    logger.i('👤 User ID: $userId');
    logger.i('📱 Device ID: $deviceId');
    logger.i('⏱️ Paired At: $pairedAt');
  }

  // Form
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Widget _buildUI(DevicePairState state, BuildContext context) {
    if (state is PairedNoPlant) {
      return Padding(
        padding: EdgeInsets.all(AppSpacingSize.l),
        child: Column(
          spacing: AppSpacingSize.l,
          children: [
            Text(
              'No Plant Added Yet',
              style: TextStyle(
                fontSize: AppFontSize.l,
                fontWeight: AppFontWeight.medium,
              ),
            ),
            Image.asset(
              'lib/assets/images/no_plant_add.png',
              width: 126,
              height: 120,
            ),
            ButtonWidget(
              text: "+ Add Plant",
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => AddPlantBottomSheet(),
                );
              },
            ),
          ],
        ),
      );
    } else if (state is PairedWithPlant) {
      return Text("login, sudah pair, dan sudah ada plant");
    }
    return const SizedBox.shrink(); // Default return for unhandled states
  }

  @override
  void initState() {
    super.initState();

    // Jalankan async task setelah build pertama selesai
    Future.microtask(() async {
      await _loadLocalStates(); // 1️⃣ load data lokal dulu
      await _initWebSocketIfPaired(); // 2️⃣ baru konek websocket
    });
  }

  Future<void> _loadLocalStates() async {
    try {
      await ref.read(sensorProvider.notifier).loadFromLocal();
      await ref.read(pumpStatusProvider.notifier).loadFromLocal();
      await ref.read(deviceStatusProvider.notifier).loadFromLocal();

      logger.i("💾 Local state loaded dari SharedPreferences");
    } catch (e, st) {
      logger.e("❌ Gagal load local state: $e", error: e, stackTrace: st);
    }
  }

  Future<void> _initWebSocketIfPaired() async {
    try {
      final deviceId = await SecureStorage.getDeviceId();

      if (deviceId != null && deviceId.isNotEmpty) {
        // Gunakan Future.microtask supaya tidak bentrok dengan initState lifecycle
        Future.microtask(() => ref.read(websocketManagerProvider).init());
        logger.i("🌐 WebSocket initialized for device: $deviceId");
      } else {
        logger.w("⚠️ Device belum terpair, WebSocket tidak dijalankan");
      }
    } catch (e, st) {
      logger.e("❌ Gagal inisialisasi WebSocket: $e", error: e, stackTrace: st);
    }
  }


  @override
  Widget build(BuildContext context) {
    final mq = MediaQueryHelper.of(context);

    final sensor = ref.watch(sensorProvider); // WEBSOCKET

    final deviceState = ref.watch(deviceProvider);

    final pairState = deviceState.activePairState;

    _logSecureStorage();

    final location = pairState != null ? 'Jakarta, Indonesia' : '-';
    final temperatureDesc = pairState != null ? 'Cloudy' : '-';
    final temperature = sensor.temperature ?? 0.0;
    final humidity = sensor.humidity ?? 0.0;
    final soil = sensor.soil ?? 0.0;
    

    if (pairState is PairedNoPlant) {
      logger.i("Pair tanpa plant: $pairState");
    } else if (pairState is PairedWithPlant) {
      logger.i("Pair dengan plant: $pairState");
    } else {
      logger.i("Belum pair");
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacingSize.l,
          right: AppSpacingSize.l,
          top: mq.notchHeight * 1.5,
        ),
        child: Column(
          children: [
            (pairState == null)
                ? AppBarWidget(
                  type: AppBarType.withoutNotif,
                  title: "Hi, Hydromers 👋",
                )
                : AppBarWidget(
                  type: AppBarType.main,
                  title: "Hi, Hydromers 👋",
                ),

            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.rm),
                border: Border.all(color: AppColors.borderOrange, width: 0.7),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSpacingSize.l),
                //  ! TOP
                child: Column(
                  children: [
                    // ? lokasi, suhu, logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: AppSpacingSize.xs,
                              children: [
                                Icon(Icons.pin_drop_outlined),
                                Text(
                                  location,
                                  style: TextStyle(fontSize: AppFontSize.m),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacingSize.s),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  temperature.toString(),
                                  style: TextStyle(
                                    fontSize: AppFontSize.xxxl,
                                    fontWeight: AppFontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '°C',
                                  style: TextStyle(
                                    fontSize: AppFontSize.xl,
                                    fontWeight: AppFontWeight.semiBold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              temperatureDesc,
                              style: TextStyle(
                                fontSize: AppFontSize.m,
                                color: AppColors.gray,
                                fontWeight: AppFontWeight.semiBold,
                              ),
                            ),
                          ],
                        ),
                        Image.asset(
                          'lib/assets/images/home_top.png',
                          width: 100,
                        ),
                      ],
                    ),

                    SizedBox(height: AppSpacingSize.xs),
                    Divider(color: AppColors.grayDivider),

                    SizedBox(height: AppSpacingSize.xs),

                    // ? humidity, moisture
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // HUMIDITY
                        Column(
                          spacing: AppSpacingSize.xs,
                          children: [
                            Text(
                              'Humidity',
                              style: TextStyle(
                                fontSize: AppFontSize.m,
                                fontWeight: AppFontWeight.semiBold,
                              ),
                            ),
                            PieChartWidget(
                              value: humidity,
                              color: AppColors.blue,
                            ),
                            StatusIndicatorWidget(
                              value: humidity,
                              type: StatusType.humidity,
                            ),
                          ],
                        ),

                        // SOIL
                        Column(
                          spacing: AppSpacingSize.xs,
                          children: [
                            Text(
                              'Soil Moisture',
                              style: TextStyle(
                                fontSize: AppFontSize.m,
                                fontWeight: AppFontWeight.semiBold,
                              ),
                            ),
                            PieChartWidget(
                              value: soil,
                              color: AppColors.success,
                            ),
                            StatusIndicatorWidget(
                              value: soil,
                              type: StatusType.soil,
                              min: 40,
                              max: 60,
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: AppSpacingSize.l),

                    Row(
                      spacing: AppSpacingSize.s,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: AppElementSize.s,
                          color: AppColors.gray,
                        ),
                        Expanded(
                          child: Text(
                            'Data updates in real-time.',
                            style: TextStyle(
                              fontSize: AppFontSize.s,
                              color: AppColors.gray,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppSpacingSize.l),

            // ! PLANT ASSIST
            Row(
              spacing: AppSpacingSize.s,
              children: [
                Icon(Icons.interests_outlined),
                Text(
                  'Plant Assistant',
                  style: TextStyle(
                    fontSize: AppFontSize.l,
                    fontWeight: AppFontWeight.semiBold,
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacingSize.xs),

            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.rm),
                border: Border.all(color: AppColors.borderOrange, width: 0.7),
              ),
              child:
                  // KALO BLOM PAIR
                  (pairState == null)
                      ? Padding(
                        padding: EdgeInsets.all(AppSpacingSize.l),
                        child: Column(
                          spacing: AppSpacingSize.l,
                          children: [
                            Text(
                              'Device Not Paired Yet',
                              style: TextStyle(
                                fontSize: AppFontSize.l,
                                fontWeight: AppFontWeight.medium,
                              ),
                            ),
                            Image.asset(
                              'lib/assets/images/no_plant_add.png',
                              width: 126,
                              height: 120,
                            ),
                            FittedBox(
                              child: Text(
                                'Make sure your device is paired to begin adding plants.',
                                style: TextStyle(fontSize: AppFontSize.m),
                              ),
                            ),
                          ],
                        ),
                      )
                      : _buildUI(pairState, context),
            ),

            SizedBox(height: AppSpacingSize.l),
          ],
        ),
      ),
    );
  }
}
