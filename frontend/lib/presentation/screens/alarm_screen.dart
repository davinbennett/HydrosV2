import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/element_size.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../core/themes/font_size.dart';
import '../../core/themes/font_weight.dart';
import '../../core/themes/radius_size.dart';
import '../../core/themes/spacing_size.dart';
import '../../core/utils/media_query_helper.dart';
import '../providers/device_provider.dart';
import '../widgets/global/app_bar.dart';
import '../widgets/global/button.dart';

class AlarmScreen extends ConsumerStatefulWidget {
  const AlarmScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AlarmPageState();
}

class _AlarmPageState extends ConsumerState<AlarmScreen> {
  bool pumpSwitch = false;
  SfRangeValues soilSlider = SfRangeValues(40.0, 80.0);

  // Dummy data
  final Map<String, dynamic> dummyResponse = {
    "next_alarm": DateTime.now().add(const Duration(hours: 5, minutes: 30)),
    "list_alarm": [
      {
        "id": 1,
        "schedule_time": DateTime.now().add(const Duration(hours: 5)),
        "is_enabled": true,
        "duration_on": 5,
        "repeat_type": 1,
      },
      {
        "id": 2,
        "schedule_time": DateTime.now().add(const Duration(hours: 24)),
        "is_enabled": false,
        "duration_on": 10,
        "repeat_type": 2,
      },
      {
        "id": 3,
        "schedule_time": DateTime.now().add(const Duration(hours: 48)),
        "is_enabled": true,
        "duration_on": 15,
        "repeat_type": 3,
      },
      {
        "id": 4,
        "schedule_time": DateTime.now().add(const Duration(hours: 48)),
        "is_enabled": true,
        "duration_on": 15,
        "repeat_type": 3,
      },
      {
        "id": 5,
        "schedule_time": DateTime.now().add(const Duration(hours: 48)),
        "is_enabled": true,
        "duration_on": 15,
        "repeat_type": 3,
      },
      {
        "id": 6,
        "schedule_time": DateTime.now().add(const Duration(hours: 48)),
        "is_enabled": true,
        "duration_on": 15,
        "repeat_type": 3,
      },
      {
        "id": 7,
        "schedule_time": DateTime.now().add(const Duration(hours: 48)),
        "is_enabled": true,
        "duration_on": 15,
        "repeat_type": 3,
      },
      {
        "id": 8,
        "schedule_time": DateTime.now().add(const Duration(hours: 48)),
        "is_enabled": true,
        "duration_on": 15,
        "repeat_type": 3,
      },
      {
        "id": 9,
        "schedule_time": DateTime.now().add(const Duration(hours: 48)),
        "is_enabled": true,
        "duration_on": 15,
        "repeat_type": 3,
      },
      {
        "id": 10,
        "schedule_time": DateTime.now().add(const Duration(hours: 48)),
        "is_enabled": true,
        "duration_on": 15,
        "repeat_type": 3,
      },
    ],
  };

  String getRepeatLabel(int type) {
    switch (type) {
      case 1:
        return "Once";
      case 2:
        return "Daily";
      case 3:
        return "Weekly";
      default:
        return "-";
    }
  }

  void _showAddAlarmModal(BuildContext context) {
    TimeOfDay selectedTime = TimeOfDay.now();
    double duration = 5;
    int repeatType = 1;
    bool enabled = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  Center(
                    child: Container(
                      width: 50,
                      height: 4,
                      margin: EdgeInsets.only(bottom: AppSpacingSize.m),
                      decoration: BoxDecoration(
                        color: AppColors.grayLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
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
                    value: duration,
                    min: 1,
                    max: 60,
                    divisions: 59,
                    activeColor: AppColors.orange,
                    label: duration.toStringAsFixed(0),
                    onChanged: (value) {
                      setModalState(() => duration = value);
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
                          DropdownMenuItem(
                            value: 3,
                            child: Text(
                              'Weekly',
                              style: TextStyle(fontSize: AppFontSize.s),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Enable switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Enabled'),
                      Switch(
                        value: enabled,
                        activeThumbColor: AppColors.orange,
                        onChanged: (value) {
                          setModalState(() => enabled = value);
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: AppSpacingSize.l),

                  // Save button
                  ButtonWidget(text: 'Save Alarm', onPressed: () {
                    Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("✅ New alarm added (dummy only)"),
                        ),
                      );
                  })
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
    final deviceState = ref.watch(deviceProvider);
    final deviceId = deviceState.pairedDeviceId;
    final alarms = dummyResponse["list_alarm"] as List;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAlarmModal(context),
        backgroundColor: AppColors.orange,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppSpacingSize.l,
            right: AppSpacingSize.l,
            top: mq.notchHeight * 1.5,
          ),
          child: Column(
            children: [
              AppBarWidget(title: 'Alarm', type: AppBarType.back),

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

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alarms.length,
                itemBuilder: (context, index) {
                  final alarm = alarms[index];
                  final scheduleTime = alarm["schedule_time"] as DateTime;

                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSpacingSize.m),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.rm),
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
                              onPressed: (context) {
                                // edit action
                              },
                              backgroundColor: AppColors.blue,
                              foregroundColor: Colors.white,
                              label: 'Edit',
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                // delete action
                              },
                              backgroundColor: AppColors.danger,
                              foregroundColor: Colors.white,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: AppSpacingSize.l,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('HH:mm').format(scheduleTime),
                                      style: TextStyle(
                                        fontSize: AppFontSize.l,
                                        fontWeight: AppFontWeight.semiBold,
                                      ),
                                    ),
                                    SizedBox(height: AppSpacingSize.xs),
                                    Text(
                                      '${getRepeatLabel(alarm["repeat_type"])} • ${alarm["duration_on"]} min',
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
                              value: alarm["is_enabled"],
                              activeThumbColor: AppColors.orange,
                              onChanged: (bool value) {
                                setState(() {
                                  alarm["is_enabled"] = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
