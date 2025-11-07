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
import '../controllers/home_controller.dart';

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
  late final HomeController homeController;

  Widget addPlantDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add Plant",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // TextField
            const TextField(
              decoration: InputDecoration(
                labelText: "Plant Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Planting Duration Plan (Week)"),
                StatefulBuilder(
                  builder: (context, setState) {
                    double duration = 4;
                    return Column(
                      children: [
                        Slider(
                          value: duration,
                          min: 1,
                          max: 52,
                          divisions: 51,
                          label: duration.round().toString(),
                          onChanged: (val) {
                            setState(() {
                              duration = val;
                            });
                          },
                        ),
                        Text("${duration.round()} Weeks"),
                      ],
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Button
            ElevatedButton(
              onPressed: () {
                // TODO: simpan data plant
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

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
                showDialog(
                  context: context,
                  builder: (_) => addPlantDialog(context),
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
    homeController = ref.read(homeControllerProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(deviceProvider, (previous, next) {
        final activePair = next.activePairState;
        if (activePair != null) {
          homeController.init();
        }
      });
    });
  }

  @override
  void dispose() {
    homeController.stopSensorListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQueryHelper.of(context);

    final homeController = ref.watch(homeControllerProvider);
    final sensorData = homeController['data'] ?? {};
    final deviceState = ref.watch(deviceProvider);

    final pairState = deviceState.activePairState;

    // _logSecureStorage();

    final location = pairState != null ? 'Jakarta, Indonesia' : '-';
    final temperatureDesc = pairState != null ? 'Cloudy' : '-';
    final temperature = pairState != null ? parseDouble(sensorData['temperature']) : '--';
    final humidity = parseDouble(sensorData['humidity']);
    final soil = parseDouble(sensorData['soil']);

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
