import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../core/themes/colors.dart';
import '../../core/themes/element_size.dart';
import '../../core/themes/font_size.dart';
import '../../core/themes/font_weight.dart';
import '../../core/themes/radius_size.dart';
import '../../core/themes/spacing_size.dart';
import '../../core/utils/media_query_helper.dart';
import '../providers/device_provider.dart';
import '../widgets/global/app_bar.dart';
import '../widgets/global/button.dart';
import '../widgets/history/line_chart.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryScreen> {
  final List<String> filters = [
    'All',
    'Today',
    'Last 7 Days',
    'This Month',
    'Date Range',
  ];

  String selectedFilter = 'All';
  DateTimeRange? selectedRange;

  final pumpFrequency = [
    FlSpot(0, 1),
    FlSpot(1, 2),
    FlSpot(2, 1.5),
    FlSpot(3, 8),
    FlSpot(4, 3.5),
    FlSpot(5, 5),
    FlSpot(6, 8),
  ];

  String getFormattedRange() {
    if (selectedRange == null) return 'Date Range';
    final df = DateFormat('dd/MM/yy');
    return '${df.format(selectedRange!.start)} - ${df.format(selectedRange!.end)}';
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final initialRange =
        selectedRange ??
        DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      initialDateRange: initialRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.orange,
              onPrimary: Colors.white,
              onSurface: AppColors.grayMedium,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedRange = picked;
        selectedFilter = 'Date Range';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQueryHelper.of(context);
    final deviceState = ref.watch(deviceProvider);
    final pairState = deviceState.activePairState;
    final deviceId = deviceState.pairedDeviceId;

    final List<Map<String, dynamic>> pumpLogs = [
      {
        'user': 'System (Auto)',
        'date': '03 Nov 2025',
        'start': '10:15',
        'end': '10:20',
        'duration': '5m',
        'moistureBefore': 40,
        'moistureAfter': 55,
      },
      {
        'user': 'Davin',
        'date': '03 Nov 2025',
        'start': '08:05',
        'end': '08:08',
        'duration': '3m',
        'moistureBefore': 42,
        'moistureAfter': 58,
      },
      {
        'user': 'System (Auto)',
        'date': '02 Nov 2025',
        'start': '21:10',
        'end': '21:15',
        'duration': '5m',
        'moistureBefore': 39,
        'moistureAfter': 53,
      },
      {
        'user': 'System (Auto)',
        'date': '02 Nov 2025',
        'start': '17:40',
        'end': '17:44',
        'duration': '4m',
        'moistureBefore': 41,
        'moistureAfter': 56,
      },
      {
        'user': 'Davin',
        'date': '02 Nov 2025',
        'start': '09:22',
        'end': '09:27',
        'duration': '5m',
        'moistureBefore': 43,
        'moistureAfter': 59,
      },
      // contoh tambahan data untuk bottom sheet
      {
        'user': 'System (Auto)',
        'date': '01 Nov 2025',
        'start': '15:10',
        'end': '15:13',
        'duration': '3m',
        'moistureBefore': 37,
        'moistureAfter': 52,
      },
    ];
    final shortList = pumpLogs.take(5).toList();

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
              AppBarWidget(title: 'History', type: AppBarType.withoutNotif),
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
      body: SingleChildScrollView(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: mq.notchHeight * 1.5),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: AppSpacingSize.l,
                  right: AppSpacingSize.l,
                ),
                child: AppBarWidget(title: 'History', type: AppBarType.main),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacingSize.l,
                    right: AppSpacingSize.l,
                  ),
                  child: Row(
                    children:
                        filters.map((filter) {
                          final isSelected = selectedFilter == filter;

                          final showCalendarIcon = filter == 'Date Range';
                          final textLabel =
                              showCalendarIcon ? getFormattedRange() : filter;

                          return Padding(
                            padding: EdgeInsets.only(right: AppSpacingSize.xs),
                            child: GestureDetector(
                              onTap: () async {
                                if (filter == 'Date Range') {
                                  await _pickDateRange(context);
                                } else {
                                  setState(() {
                                    selectedFilter = filter;
                                    selectedRange = null;
                                  });
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacingSize.m,
                                  vertical: AppSpacingSize.s * 0.8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? AppColors.orange.withOpacity(0.1)
                                          : AppColors.white,
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? AppColors.orange
                                            : AppColors.borderOrange,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.rfull,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (showCalendarIcon)
                                      Padding(
                                        padding: EdgeInsets.only(
                                          right: AppSpacingSize.xs,
                                        ),
                                        child: Icon(
                                          Icons.calendar_today_rounded,
                                          size: AppFontSize.m,
                                          color:
                                              isSelected
                                                  ? AppColors.orange
                                                  : AppColors.grayLight,
                                        ),
                                      ),
                                    Text(
                                      textLabel,
                                      style: TextStyle(
                                        fontSize: AppFontSize.s,
                                        fontWeight:
                                            isSelected
                                                ? AppFontWeight.semiBold
                                                : AppFontWeight.normal,
                                        color:
                                            isSelected
                                                ? AppColors.orange
                                                : AppColors.grayLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),

              SizedBox(height: AppSpacingSize.xl),

              // ! === DEBUG ===
              // Center(
              //   child: Text(
              // selectedFilter == 'Date Range'
              //     ? 'Showing data from ${getFormattedRange()}'
              //     : 'Showing data for $selectedFilter',
              //     style: TextStyle(
              //       fontSize: AppFontSize.m,
              //       color: AppColors.grayMedium,
              //     ),
              //   ),
              // ),
              Padding(
                padding: EdgeInsets.only(
                  left: AppSpacingSize.l,
                  right: AppSpacingSize.l,
                ),
                child: Row(
                  spacing: AppSpacingSize.s,
                  children: [
                    Icon(Icons.sticky_note_2_outlined),
                    Text(
                      'Environmental Averages',
                      style: TextStyle(
                        fontSize: AppFontSize.l,
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacingSize.xs),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacingSize.l,
                    right: AppSpacingSize.l,
                  ),
                  child: Row(
                    spacing: AppSpacingSize.s,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(AppRadius.rxl),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacingSize.l),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: AppSpacingSize.xs,
                                children: [
                                  Text(
                                    'Temperature',
                                    style: TextStyle(
                                      fontSize: AppFontSize.m,
                                      fontWeight: AppFontWeight.semiBold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedTemperature,
                                    size: AppElementSize.xxl,
                                    color: AppColors.white,
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpacingSize.m),
                              Text(
                                '30',
                                style: TextStyle(
                                  fontSize: AppFontSize.xxl,
                                  fontWeight: AppFontWeight.semiBold,
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                '°C',
                                style: TextStyle(
                                  fontSize: AppFontSize.l,
                                  fontWeight: AppFontWeight.semiBold,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          borderRadius: BorderRadius.circular(AppRadius.rxl),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacingSize.l),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: AppSpacingSize.s,
                                children: [
                                  Text(
                                    'Humidity',
                                    style: TextStyle(
                                      fontSize: AppFontSize.m,
                                      fontWeight: AppFontWeight.semiBold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedHumidity,
                                    size: AppElementSize.xxl,
                                    color: AppColors.white,
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpacingSize.m),
                              Text(
                                '30',
                                style: TextStyle(
                                  fontSize: AppFontSize.xxl,
                                  fontWeight: AppFontWeight.semiBold,
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                '%',
                                style: TextStyle(
                                  fontSize: AppFontSize.l,
                                  fontWeight: AppFontWeight.semiBold,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(AppRadius.rxl),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacingSize.l),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: AppSpacingSize.s,
                                children: [
                                  Text(
                                    'Soil Moisture',
                                    style: TextStyle(
                                      fontSize: AppFontSize.m,
                                      fontWeight: AppFontWeight.semiBold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  HugeIcon(
                                    icon:
                                        HugeIcons
                                            .strokeRoundedSoilMoistureField,
                                    size: AppElementSize.xxl,
                                    color: AppColors.white,
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpacingSize.m),
                              Text(
                                '30',
                                style: TextStyle(
                                  fontSize: AppFontSize.xxl,
                                  fontWeight: AppFontWeight.semiBold,
                                  color: AppColors.white,
                                ),
                              ),
                              Text(
                                '%',
                                style: TextStyle(
                                  fontSize: AppFontSize.l,
                                  fontWeight: AppFontWeight.semiBold,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppSpacingSize.l),

              Padding(
                padding: EdgeInsets.only(
                  left: AppSpacingSize.l,
                  right: AppSpacingSize.l,
                ),
                child: Row(
                  spacing: AppSpacingSize.s,
                  children: [
                    Icon(Icons.sticky_note_2_outlined),
                    Text(
                      'Water Flow Activity',
                      style: TextStyle(
                        fontSize: AppFontSize.l,
                        fontWeight: AppFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        '30',
                        style: TextStyle(
                          fontSize: AppFontSize.xxl,
                          fontWeight: AppFontWeight.semiBold,
                        ),
                      ),
                      Text('Total Pumps'),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '30',
                        style: TextStyle(
                          fontSize: AppFontSize.xxl,
                          fontWeight: AppFontWeight.semiBold,
                        ),
                      ),
                      Text('Average Duration'),
                    ],
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsets.only(
                  top: AppSpacingSize.s,
                  left: AppSpacingSize.l,
                  right: AppSpacingSize.l,
                ),
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
                    padding: EdgeInsets.symmetric(vertical: AppSpacingSize.m),
                    child: LineChartWidget(
                      title: 'Pump Activation Frequency',
                      yLabel: 'Times',
                      bottomLabels: [
                        '00:00',
                        '04:00',
                        '08:00',
                        '12:00',
                        '16:00',
                        '20:00',
                        '23:59',
                      ],
                      data: pumpFrequency,
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppSpacingSize.l),

              Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacingSize.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Details',
                style: TextStyle(
                  fontWeight: AppFontWeight.medium,
                  fontSize: AppFontSize.m,
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    showDragHandle: true,
                    isScrollControlled: true,
                    backgroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.rxl),
                      ),
                    ),
                    builder: (context) => FractionallySizedBox(
                      heightFactor: 0.85,
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacingSize.l),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Pump History',
                              style: TextStyle(
                                fontSize: AppFontSize.l,
                                fontWeight: AppFontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: ListView.builder(
                                itemCount: pumpLogs.length,
                                itemBuilder: (context, index) =>
                                    _PumpHistoryItem(pumpLogs[index]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: AppFontWeight.medium,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// List preview
          ListView.builder(
            itemCount: shortList.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => _PumpHistoryItem(shortList[index]),
          ),
        ],
      ),
    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PumpHistoryItem extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PumpHistoryItem(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacingSize.s),
      padding: EdgeInsets.all(AppSpacingSize.m),
      decoration: BoxDecoration(
        color: AppColors.grayLight,
        borderRadius: BorderRadius.circular(AppRadius.rl),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.heat_pump,
              color: AppColors.success,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['user'],
                  style: TextStyle(
                    fontWeight: AppFontWeight.semiBold,
                    fontSize: AppFontSize.s,
                  ),
                ),
                Text(
                  '${data['date']} — ${data['start']}–${data['end']} (${data['duration']})',
                  style: TextStyle(
                    fontSize: AppFontSize.s,
                    color: AppColors.grayMedium,
                  ),
                ),
                Text(
                  'Soil Moisture: ${data['moistureBefore']}% → ${data['moistureAfter']}%',
                  style: TextStyle(
                    fontSize: AppFontSize.s,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
