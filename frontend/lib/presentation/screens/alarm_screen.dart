import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../core/themes/font_size.dart';
import '../../core/themes/font_weight.dart';
import '../../core/themes/radius_size.dart';
import '../../core/themes/spacing_size.dart';
import '../../core/utils/media_query_helper.dart';
import '../../core/utils/toIsoWithOffset.dart';
import '../../infrastructure/local/secure_storage.dart';
import '../providers/alarm_provider.dart';
import '../providers/injection.dart';
import '../providers/websocket/device_status_provider.dart';
import '../widgets/alarm/app_bar.dart';
import '../widgets/global/button.dart';
import '../widgets/global/loading.dart';

class AlarmScreen extends ConsumerStatefulWidget {
  const AlarmScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AlarmPageState();
}

late DeviceStatusState device;

class _AlarmPageState extends ConsumerState<AlarmScreen> {
  bool pumpSwitch = false;
  SfRangeValues soilSlider = SfRangeValues(40.0, 80.0);
  bool isLoading = false;

  String getRepeatLabel(int type) {
    switch (type) {
      case 1:
        return "Once";
      case 2:
        return "Daily";
      // case 3:
      //   return "Weekly";
      default:
        return "-";
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final deviceId = await SecureStorage.getDeviceId();
      if (deviceId != null && deviceId.isNotEmpty) {
        await ref.read(alarmProvider.notifier).loadAlarm(deviceId);
      }
    });
  }

  void _showAddAlarmModal(BuildContext context) {
    TimeOfDay selectedTime = TimeOfDay.now();
    int duration = 5;
    int repeatType = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.rl)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacingSize.l,
            right: AppSpacingSize.l,
            top: AppSpacingSize.l,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacingSize.l,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add New Alarm',
                    style: TextStyle(
                      fontSize: AppFontSize.l,
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),
                  SizedBox(height: AppSpacingSize.m),

                  // Time picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Select Time'),
                    subtitle: Text(selectedTime.format(context)),
                    trailing: Icon(Icons.access_time, color: AppColors.orange),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setModalState(() => selectedTime = picked);
                      }
                    },
                  ),

                  SizedBox(height: AppSpacingSize.m),

                  // Duration slider
                  Text('Duration of pump on (minutes)'),
                  Slider(
                    value: duration.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    activeColor: AppColors.orange,
                    label: duration.toStringAsFixed(0),
                    onChanged: (value) {
                      setModalState(() => duration = value.toInt());
                    },
                  ),

                  SizedBox(height: AppSpacingSize.m),

                  // Repeat type dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Repeat Type'),
                      DropdownButton<int>(
                        value: repeatType,
                        onChanged: (value) {
                          setModalState(() => repeatType = value ?? 1);
                        },
                        items: [
                          DropdownMenuItem(
                            value: 1,
                            child: Text(
                              'Once',
                              style: TextStyle(fontSize: AppFontSize.s),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(
                              'Daily',
                              style: TextStyle(fontSize: AppFontSize.s),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacingSize.l),

                  // Save button
                  ButtonWidget(
                    text: 'Save Alarm',
                    onPressed: () {
                      _handleAddAlarm(selectedTime, duration, repeatType);
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handleAddAlarm(
    TimeOfDay selectedTime,
    int duration,
    int repeatType,
  ) async {
    if (!mounted) return;
    context.pop();

    // ==== CEK STATUS KONEKSI ====
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

    // ==== Ambil Device ID ====
    final deviceId = await SecureStorage.getDeviceId();
    if (deviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Device ID not found."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // ==== Build schedule_time ====
    final now = DateTime.now();
    final scheduleTime = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Jika sudah lewat → jadikan besok
    DateTime finalSchedule = scheduleTime;
    if (scheduleTime.isBefore(now)) {
      finalSchedule = scheduleTime.add(const Duration(days: 1));
    }

    // Format → ISO 8601 local zona WIB (+07:00)
    final formattedSchedule = toIso8601WithOffset(finalSchedule);

    // ==== Panggil AlarmController ====
    try {
      final controller = ref.read(alarmControllerProvider);

      final result = await controller.postAlarmController(
        deviceId,
        formattedSchedule,
        duration,
        repeatType,
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      ref.read(alarmProvider.notifier).addAlarm({
        "id": result,
        "schedule_time": formattedSchedule,
        "duration_on": duration,
        "repeat_type": repeatType,
        "is_enabled": true,
      });
      await ref.read(alarmProvider.notifier).loadAlarm(deviceId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alarm added successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  Future<void> _handleSwitchEnable(Map<String, dynamic> alarm, bool value) async {
    // ==== CEK STATUS KONEKSI ====
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
    if (deviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Device ID not found."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final alarmId = alarm["id"];

    try {
      final controller = ref.read(alarmControllerProvider);
      
      final result = await controller.updateEnableAlarmController(
        alarmId,
        deviceId,
        value,
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      ref.read(alarmProvider.notifier).updateEnabledFromUI(alarmId.toString(), value);
      await ref.read(alarmProvider.notifier).loadAlarm(deviceId);

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

  Future<void> _handleDeleteAlarm(Map<String, dynamic> alarm) async {
    // ==== CEK STATUS KONEKSI ====
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
    if (deviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Device ID not found."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final alarmId = alarm["id"];

    try {
      final controller = ref.read(alarmControllerProvider);

      final result = await controller.deleteAlarmController(
        alarmId,
        deviceId,
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      ref
          .read(alarmProvider.notifier)
          .removeAlarm(alarmId);
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

  void _showConfirmDelete(Map<String, dynamic> alarm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Delete Alarm",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to delete this alarm? This action can't be undo.",
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                _handleDeleteAlarm(alarm);
              },
              child: const Text("Delete", style: TextStyle(color: AppColors.danger)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleUpdateAlarm(
    int alarmId,
    TimeOfDay time,
    int duration,
    int repeatType,
    bool isEnabled,
  ) async {
    if (!mounted) return;
    context.pop();

    // ==== CEK STATUS KONEKSI ====
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

    // ==== Ambil Device ID ====
    final deviceId = await SecureStorage.getDeviceId();
    if (!mounted) return;
    if (deviceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Device ID not found."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // ==== Build schedule_time ====
    final now = DateTime.now();
    final scheduleTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Jika sudah lewat → jadikan besok
    DateTime finalSchedule = scheduleTime;
    if (scheduleTime.isBefore(now)) {
      finalSchedule = scheduleTime.add(const Duration(days: 1));
    }

    // Format → ISO 8601 local zona WIB (+07:00)
    final formattedSchedule = toIso8601WithOffset(finalSchedule);

    // ==== Panggil AlarmController ====
    try {
      final controller = ref.read(alarmControllerProvider);

      final result = await controller.updateAlarmController(
        alarmId,
        deviceId,
        formattedSchedule,
        duration,
        repeatType,
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      ref.read(alarmProvider.notifier).updateAlarm({
        "id": alarmId,
        "schedule_time": formattedSchedule,
        "duration_on": duration,
        "repeat_type": repeatType,
        "is_enabled": isEnabled,
      });

      await ref.read(alarmProvider.notifier).loadAlarm(deviceId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alarm updated successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  void _showEditAlarmModal(BuildContext context, Map<String, dynamic> alarm) 
  {
    // =========== SET DEFAULT VALUE dari alarm ===========
    final scheduleStr = alarm["schedule_time"];

    // parse ISO time example: "2025-11-16T00:01:00+07:00"
    final dt = DateTime.parse(scheduleStr).toLocal();

    final initialTime = TimeOfDay(hour: dt.hour, minute: dt.minute);

    TimeOfDay selectedTime = initialTime;
    int duration = alarm["duration_on"] ?? 5;
    int repeatType = alarm["repeat_type"] ?? 1;
    bool isEnabled = alarm["is_enabled"] ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.rl)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacingSize.l,
            right: AppSpacingSize.l,
            top: AppSpacingSize.l,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacingSize.l,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================== TITLE ==================
                  Text(
                    'Edit Alarm',
                    style: TextStyle(
                      fontSize: AppFontSize.l,
                      fontWeight: AppFontWeight.semiBold,
                    ),
                  ),

                  SizedBox(height: AppSpacingSize.m),

                  // ================== TIME PICKER ==================
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Select Time'),
                    subtitle: Text(selectedTime.format(context)),
                    trailing: Icon(Icons.access_time, color: AppColors.orange),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setModalState(() => selectedTime = picked);
                      }
                    },
                  ),

                  SizedBox(height: AppSpacingSize.m),

                  // ================== DURATION ==================
                  Text('Duration of pump on (minutes)'),
                  Slider(
                    value: duration.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    activeColor: AppColors.orange,
                    label: duration.toStringAsFixed(0),
                    onChanged: (value) {
                      setModalState(() => duration = value.toInt());
                    },
                  ),

                  SizedBox(height: AppSpacingSize.m),

                  // ================== REPEAT TYPE ==================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Repeat Type'),
                      DropdownButton<int>(
                        value: repeatType,
                        onChanged: (value) {
                          setModalState(() => repeatType = value ?? 1);
                        },
                        items: [
                          DropdownMenuItem(
                            value: 1,
                            child: Text(
                              'Once',
                              style: TextStyle(fontSize: AppFontSize.s),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(
                              'Daily',
                              style: TextStyle(fontSize: AppFontSize.s),
                            ),
                          ),
                          // DropdownMenuItem(
                          //   value: 3,
                          //   child: Text(
                          //     'Weekly',
                          //     style: TextStyle(fontSize: AppFontSize.s),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacingSize.l),

                  // ================== UPDATE BUTTON ==================
                  ButtonWidget(
                    text: 'Update Alarm',
                    onPressed: () {
                      _handleUpdateAlarm(
                        alarm["id"],
                        selectedTime,
                        duration,
                        repeatType,
                        isEnabled,
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final mq = MediaQueryHelper.of(context);
    final alarmState = ref.watch(alarmProvider);

    device = ref.watch(deviceStatusProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAlarmModal(context),
        backgroundColor: AppColors.orange,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children:[
          SingleChildScrollView(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacingSize.l,
                right: AppSpacingSize.l,
                top: mq.notchHeight * 1.5,
              ),
              child: Column(
                children: [
                  AppBarAlarmWidget(
                    title: 'Alarm', 
                    type: AppBarAlarmType.back,
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: AppSpacingSize.xl),
                    child: Row(
                      spacing: AppSpacingSize.s,
                      children: [
                        HugeIcon(icon: HugeIcons.strokeRoundedAlarmClock),
                        Text(
                          'Your Alarm List',
                          style: TextStyle(
                            fontSize: AppFontSize.l,
                            fontWeight: AppFontWeight.semiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (alarmState.listAlarm.isEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: AppSpacingSize.l),
                      child: Text(
                        'No alarms yet.',
                        style: TextStyle(
                          fontSize: AppFontSize.m,
                          fontWeight: AppFontWeight.semiBold,
                          color: AppColors.grayMedium,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.only(bottom: AppSpacingSize.xxxl),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: alarmState.listAlarm.length,
                        itemBuilder: (context, index) {
                          final alarm = alarmState.listAlarm[index];
                          final scheduleTime =
                              alarm["schedule_time"] is String
                                  ? DateTime.parse(
                                    alarm["schedule_time"],
                                  ).toLocal()
                                  : (alarm["schedule_time"] as DateTime?)
                                          ?.toLocal() ??
                                      DateTime.now();
                          final durationOn = alarm["duration_on"] ?? 0;
                          final repeatType = alarm["repeat_type"] ?? 1;
                          final isEnabled = alarm["is_enabled"] ?? false;

                          return Padding(
                            padding: EdgeInsets.only(bottom: AppSpacingSize.m),
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.rm,
                                ),
                                border: Border.all(
                                  color: AppColors.borderOrange,
                                  width: 0.7,
                                ),
                              ),
                              child: Slidable(
                                key: ValueKey(alarm["id"]),
                                endActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (_) {
                                        _showEditAlarmModal(context, alarm);
                                      },
                                      backgroundColor: AppColors.blue,
                                      foregroundColor: Colors.white,
                                      label: 'Edit',
                                    ),
                                    SlidableAction(
                                      onPressed: (context) {
                                        // delete action
                                        _showConfirmDelete(alarm);
                                      },
                                      backgroundColor: AppColors.danger,
                                      foregroundColor: Colors.white,
                                      label: 'Delete',
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: AppSpacingSize.l,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              DateFormat(
                                                'HH:mm',
                                              ).format(scheduleTime),
                                              style: TextStyle(
                                                fontSize: AppFontSize.l,
                                                fontWeight:
                                                    AppFontWeight.semiBold,
                                              ),
                                            ),
                                            SizedBox(height: AppSpacingSize.xs),
                                            Text(
                                              '${getRepeatLabel(repeatType)} • $durationOn min',
                                              style: TextStyle(
                                                fontSize: AppFontSize.s,
                                                color: AppColors.grayMedium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Switch(
                                      padding: EdgeInsets.only(
                                        top: AppSpacingSize.xxl,
                                        right: AppSpacingSize.xl,
                                      ),
                                      value: isEnabled,
                                      activeThumbColor: AppColors.orange,
                                      onChanged: (value) {
                                        _handleSwitchEnable(alarm, value);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isLoading) LoadingWidget(),
        ], 
      ),
    );
  }
}
