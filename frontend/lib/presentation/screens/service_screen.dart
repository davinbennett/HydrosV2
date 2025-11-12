import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/element_size.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../core/themes/font_size.dart';
import '../../core/themes/font_weight.dart';
import '../../core/themes/radius_size.dart';
import '../../core/themes/spacing_size.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/media_query_helper.dart';
import '../../infrastructure/local/secure_storage.dart';
import '../providers/device_provider.dart';
import '../providers/injection.dart';
import '../providers/websocket/device_status_provider.dart';
import '../providers/websocket/pump_status_provider.dart';
import '../widgets/global/app_bar.dart';
import '../widgets/global/button.dart';
import '../widgets/global/loading.dart';

class ServiceScreen extends ConsumerStatefulWidget {
  const ServiceScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ServicePageState();
}

late DeviceStatusState device;

class _ServicePageState extends ConsumerState<ServiceScreen> {
  SfRangeValues soilSlider = SfRangeValues(0.0, 0.0);
  bool isLoading = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await _loadSoilSetting();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSoilSetting() async {
    final deviceId = await SecureStorage.getDeviceId();
    final serviceController = ref.read(serviceControllerProvider);

    try {
      final result = await serviceController.getSoilSettingController(
        deviceId!,
      );

      if (!mounted) return;

      if (result.isNotEmpty) {
        final min = result['min_soil_setting']?.toDouble() ?? 0.0;
        final max = result['max_soil_setting']?.toDouble() ?? 100.0;

        setState(() {
          soilSlider = SfRangeValues(min, max);
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSwitchPump(bool value) async {
    if (!mounted) return;
    if (device.status != "stable") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Connection unstable. Please wait until the status above is green.",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    final deviceId = await SecureStorage.getDeviceId();
    final serviceController = ref.read(serviceControllerProvider);

    try {
      final result = await serviceController.controlPumpSwitchController(
        deviceId!,
        value,
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      if (result == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to control pump. Try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSoilSetting(SfRangeValues values) async {
    setState(() {
      soilSlider = values;
    });
    if (!mounted) return;
    if (device.status != "stable") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Connection unstable. Please wait until the status above is green.",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      setState(() => isLoading = true);
      final deviceId = await SecureStorage.getDeviceId();
      final serviceController = ref.read(serviceControllerProvider);

      try {
        final result = await serviceController.controlPumpSoilSettingController(
          deviceId!,
          values.start.toInt(),
          values.end.toInt(),
        );

        if (!mounted) return;
        setState(() => isLoading = false);

        if (result == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to control with soil setting. Try again.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        
      } catch (e) {
        if (!mounted) return;
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    final mq = MediaQueryHelper.of(context);
    final deviceState = ref.watch(deviceProvider);
    final pairState = deviceState.activePairState;
    final deviceId = deviceState.pairedDeviceId;

    final pump = ref.watch(pumpStatusProvider);
    final pumpSwitch = (pump.pumpStatus ?? false) ? true : false;
    device = ref.watch(deviceStatusProvider);

    if (pairState == null) {
      // Jika belum ada device yang dipair
      return Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppSpacingSize.l,
            right: AppSpacingSize.l,
            top: mq.notchHeight * 1.5,
          ),
          child: Column(
            children: [
              AppBarWidget(title: 'Service', type: AppBarType.withoutNotif),
              Padding(
                padding: EdgeInsets.only(
                  top: mq.screenHeight / 2 - 126,
                  left: AppSpacingSize.xxl * 2,
                  right: AppSpacingSize.xxl * 2,
                ),
                child: Center(
                  child: ButtonWidget(
                    icon: Icons.link,
                    onPressed: () {
                      context.push('/pair-device');
                    },
                    text: 'Pair Device',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: AppSpacingSize.l,
              right: AppSpacingSize.l,
              top: mq.notchHeight * 1.5,
            ),
            child: Column(
              children: [
                AppBarWidget(title: 'Service', type: AppBarType.main),

                Row(
                  spacing: AppSpacingSize.s,
                  children: [
                    Icon(Icons.sticky_note_2_outlined),
                    Text(
                      'Quick Activity',
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
                    border: Border.all(
                      color: AppColors.borderOrange,
                      width: 0.7,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacingSize.l),
                    child: Column(
                      spacing: AppSpacingSize.m,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: AppSpacingSize.s,
                          children: [
                            Row(
                              spacing: AppSpacingSize.s,
                              children: [
                                Icon(Icons.schedule_outlined),
                                Text(
                                  'Last Pumped',
                                  style: TextStyle(
                                    fontSize: AppFontSize.m,
                                    fontWeight: AppFontWeight.medium,
                                  ),
                                ),
                              ],
                            ),
                            Flexible(
                              child: Text(
                                'Jul 5’ 25 - 14:00:00',
                                style: TextStyle(
                                  fontSize: AppFontSize.m,
                                  fontWeight: AppFontWeight.medium,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: AppSpacingSize.s,
                          children: [
                            Row(
                              spacing: AppSpacingSize.s,
                              children: [
                                HugeIcon(
                                  icon:
                                      HugeIcons
                                          .strokeRoundedSoilTemperatureField,
                                ),
                                Text(
                                  'Soil Range',
                                  style: TextStyle(
                                    fontSize: AppFontSize.m,
                                    fontWeight: AppFontWeight.medium,
                                  ),
                                ),
                              ],
                            ),
                            Flexible(
                              child: Text(
                                'Min: ${soilSlider.start.toInt()}% | Max: ${soilSlider.end.toInt()}%',
                                style: TextStyle(
                                  fontSize: AppFontSize.m,
                                  fontWeight: AppFontWeight.medium,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: AppSpacingSize.s,
                          children: [
                            Row(
                              spacing: AppSpacingSize.s,
                              children: [
                                Icon(Icons.next_plan_outlined),
                                Text(
                                  'Next Alarm Pump',
                                  style: TextStyle(
                                    fontSize: AppFontSize.m,
                                    fontWeight: AppFontWeight.medium,
                                  ),
                                ),
                              ],
                            ),
                            Flexible(
                              child: Text(
                                'Jul 5’ 25 - 14:00:00',
                                style: TextStyle(
                                  fontSize: AppFontSize.m,
                                  fontWeight: AppFontWeight.medium,
                                  fontStyle: FontStyle.italic,
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

                Row(
                  spacing: AppSpacingSize.s,
                  children: [
                    Icon(Icons.settings_remote_outlined),
                    Text(
                      'Device Control',
                      style: TextStyle(
                        fontSize: AppFontSize.l,
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSpacingSize.xs),

                IntrinsicHeight(
                  child: Row(
                    spacing: AppSpacingSize.s,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppRadius.rm),
                            border: Border.all(
                              color: AppColors.borderOrange,
                              width: 0.7,
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacingSize.l),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedWaterPump,
                                      size: AppElementSize.xl,
                                    ),
                                    Transform.scale(
                                      scale: 0.95,
                                      child: Switch(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        value: pumpSwitch,
                                        onChanged:
                                            (value) => _handleSwitchPump(value),
                                        activeThumbColor: AppColors.orange,
                                        padding: EdgeInsets.all(0),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppSpacingSize.xxxl),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  spacing: AppSpacingSize.s,
                                  children: [
                                    Text(
                                      'Pump',
                                      style: TextStyle(
                                        fontSize: AppFontSize.m,
                                        fontWeight: AppFontWeight.semiBold,
                                      ),
                                    ),
                                    Text(
                                      pumpSwitch ? 'On' : 'Off',
                                      style: TextStyle(
                                        fontSize: AppFontSize.s,
                                        color: AppColors.grayMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppRadius.rm),
                            border: Border.all(
                              color: AppColors.borderOrange,
                              width: 0.7,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: AppSpacingSize.l,
                                  left: AppSpacingSize.l,
                                  right: AppSpacingSize.l,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    HugeIcon(
                                      icon:
                                          HugeIcons
                                              .strokeRoundedSoilMoistureField,
                                      size: AppElementSize.xl,
                                    ),
                                    Text(
                                      'Soil Setting',
                                      style: TextStyle(
                                        fontWeight: AppFontWeight.semiBold,
                                        fontSize: AppFontSize.m,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SfRangeSlider(
                                min: 0.0,
                                max: 100.0,
                                values: soilSlider,
                                interval: 50,
                                showTicks: true,
                                showLabels: true,
                                enableTooltip: true,
                                onChanged:
                                    (SfRangeValues values) =>
                                        _handleSoilSetting(values),
                                stepSize: 1,
                                activeColor: AppColors.orange,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: AppSpacingSize.xs,
                                  left: AppSpacingSize.l,
                                  right: AppSpacingSize.l,
                                  bottom: AppSpacingSize.l,
                                ),
                                child: Text(
                                  'Set soil moisture range for auto irrigation',
                                  style: TextStyle(
                                    color: AppColors.grayMedium,
                                    fontSize: AppFontSize.s,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSpacingSize.l),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.rm),
                    border: Border.all(
                      color: AppColors.borderOrange,
                      width: 0.7,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacingSize.l),
                    child: Column(
                      spacing: AppSpacingSize.s,
                      children: [
                        Text(
                          'Alarm in 2 days 17 hours 32 minutes',
                          style: TextStyle(
                            fontSize: AppFontSize.m,
                            fontWeight: AppFontWeight.semiBold,
                          ),
                        ),
                        Divider(color: AppColors.grayDivider),

                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            context.push('/alarm');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                spacing: AppSpacingSize.s,
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedAlarmClock,
                                    size: AppElementSize.xl,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Alarm',
                                        style: TextStyle(
                                          fontSize: AppFontSize.m,
                                          fontWeight: AppFontWeight.semiBold,
                                        ),
                                      ),
                                      Text(
                                        'Schedule pump with alarm',
                                        style: TextStyle(
                                          color: AppColors.grayMedium,
                                          fontSize: AppFontSize.s,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Transform.translate(
                                offset: Offset(8.0, 0.0),
                                child: Icon(Icons.keyboard_arrow_right_rounded),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (isLoading) LoadingWidget(),
        ],
      ),
    );
  }
}
