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
import '../../core/utils/monthname.dart';
import '../../core/utils/triggeredby.dart';
import '../../infrastructure/local/secure_storage.dart';
import '../providers/device_provider.dart';
import '../providers/injection.dart';
import '../widgets/global/app_bar.dart';
import '../widgets/global/button.dart';
import '../widgets/global/loading.dart';
import '../widgets/history/line_chart.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryScreen> {
  double avgTemp = 0.0;
  double avgHum = 0.0;
  double avgSoil = 0.0;

  int totalPump = 0;
  double avgDuration = 0.0;

  bool isLoading = false;

  final List<String> filters = [
    'All',
    'Today',
    'Last 7 Days',
    'This Month',
    'Date Range',
  ];

  String selectedFilter = 'All';
  DateTimeRange? selectedRange;

  List<FlSpot> pumpFrequency = [
    FlSpot(0, 0),
    FlSpot(1, 0),
    FlSpot(2, 0),
    FlSpot(3, 0),
    FlSpot(4, 0),
    FlSpot(5, 0),
    FlSpot(6, 0),
  ];

  List<Map<String, dynamic>> pumpLogs = [
    {
      'user': '',
      'date': '',
      'start': '',
      'end': '',
      'duration': '0m',
      'moistureBefore': 0,
      'moistureAfter': 0,
    },
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final deviceId = await SecureStorage.getDeviceId();
      if (deviceId != null && deviceId.isNotEmpty) {
        await _loadAggregatedData(deviceId);
        await _loadWaterFlowActivity(deviceId);
      }
    });
  }

  Future<void> _loadWaterFlowActivity(String deviceId) async {
    setState(() {
      isLoading = true;
    });

    final historyController = ref.read(historyControllerProvider);

    bool isToday = selectedFilter == 'Today';
    bool isLastDay = selectedFilter == 'Last 7 Days';
    bool isThisMonth = selectedFilter == 'This Month';

    String startDate = '';
    String endDate = '';

    if (selectedFilter == 'Date Range' && selectedRange != null) {
      startDate = DateFormat('yyyy-MM-dd').format(selectedRange!.start);
      endDate = DateFormat('yyyy-MM-dd').format(selectedRange!.end);
    }

    try {
      final result = await historyController
          .getWaterFlowActivityController(
            deviceId,
            isToday,
            isLastDay,
            isThisMonth,
            startDate,
            endDate,
          );

      final total = result['total_pump'];
      final avg = result['average_duration'];
      
      final details = (result['detail'] ?? []);

      List<Map<String, dynamic>> convertedLogs = [];

      for (var d in details) {
        final start = d['start_time'] ?? "";
        final end = d['end_time'] ?? "";
        final duration = d['time_difference'] ?? "";
        final triggeredBy = mapTriggeredBy(d['triggered_by']);
        final before = d['soil_before'] ?? 0;
        final after = d['soil_after'] ?? 0;

        // Convert ISO → display date
        // Example "2025-11-20T10:15:00Z"
        DateTime? parsed = DateTime.tryParse(start);

        String formattedDate = "";
        String formattedStart = "";
        String formattedEnd = "";

        if (parsed != null) {
          final local = parsed.toLocal();

          formattedDate =
              "${local.day.toString().padLeft(2, '0')} ${monthName(local.month)} ${local.year}";

          formattedStart =
              "${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
        }


        DateTime? parsedEnd = DateTime.tryParse(end);
        if (parsedEnd != null) {
          final localEnd = parsedEnd.toLocal();
          formattedEnd =
              "${localEnd.hour.toString().padLeft(2, '0')}:${localEnd.minute.toString().padLeft(2, '0')}";
        }

        convertedLogs.add({
          'user': triggeredBy,
          'date': formattedDate,
          'start': formattedStart,
          'end': formattedEnd,
          'duration': duration,
          'moistureBefore': before,
          'moistureAfter': after,
        });
      }


      final List<dynamic> freq = result['chart_frequency'] ?? [];
      final List<FlSpot> chart = [];

      for (int i = 0; i < freq.length; i++) {
        final value = double.tryParse(freq[i].toString()) ?? 0.0;
        chart.add(FlSpot(i.toDouble(), value));
      }

      if (!mounted) return;

      setState(() {
        totalPump = total;
        avgDuration = avg;
        pumpLogs = convertedLogs;
        pumpFrequency = chart;
        isLoading = false;
      });
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

  String formatNumber(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    final double convertedDouble = (value as num).toDouble();
    return double.parse(convertedDouble.toStringAsFixed(2));
  }

  Future<void> _loadAggregatedData(String deviceId) async {
    setState(() => isLoading = true);

    final historyController = ref.read(historyControllerProvider);

    bool isToday = selectedFilter == 'Today';
    bool isLastDay = selectedFilter == 'Last 7 Days';
    bool isThisMonth = selectedFilter == 'This Month';

    String startDate = '';
    String endDate = '';

    if (selectedFilter == 'Date Range' && selectedRange != null) {
      startDate = DateFormat('yyyy-MM-dd').format(selectedRange!.start);
      endDate = DateFormat('yyyy-MM-dd').format(selectedRange!.end);
    }

    try {
      final result = await historyController.getSensorAggregatedController(
        deviceId,
        isToday,
        isLastDay,
        isThisMonth,
        startDate,
        endDate,
      );

      if (!mounted) return;

      setState(() {
        avgTemp = _toDouble(result['avg_temperature']);
        avgHum = _toDouble(result['avg_humidity']);
        avgSoil = _toDouble(result['avg_soil']);
        isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    final mq = MediaQueryHelper.of(context);
    final deviceState = ref.watch(deviceProvider);
    final pairState = deviceState.activePairState;
    final deviceId = deviceState.pairedDeviceId;

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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: mq.notchHeight * 1.5),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppSpacingSize.l,
                      right: AppSpacingSize.l,
                    ),
                    child: AppBarWidget(
                      title: 'History',
                      type: AppBarType.main,
                    ),
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
                                  showCalendarIcon
                                      ? getFormattedRange()
                                      : filter;

                              return Padding(
                                padding: EdgeInsets.only(
                                  right: AppSpacingSize.xs,
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (filter == 'Date Range') {
                                      await _pickDateRange(context);
                                      if (selectedRange != null) {
                                        await _loadAggregatedData(deviceId!);
                                        await _loadWaterFlowActivity(deviceId);
                                      }
                                    } else {
                                      setState(() {
                                        selectedFilter = filter;
                                        selectedRange = null;
                                      });

                                      await _loadAggregatedData(deviceId!);
                                      await _loadWaterFlowActivity(deviceId);
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
                                              ? AppColors.orange.withOpacity(
                                                0.1,
                                              )
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
                              borderRadius: BorderRadius.circular(
                                AppRadius.rxl,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacingSize.l),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        icon:
                                            HugeIcons.strokeRoundedTemperature,
                                        size: AppElementSize.xxl,
                                        color: AppColors.white,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppSpacingSize.m),
                                  Text(
                                    formatNumber(avgTemp),
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
                              borderRadius: BorderRadius.circular(
                                AppRadius.rxl,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacingSize.l),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    formatNumber(avgHum),
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
                              borderRadius: BorderRadius.circular(
                                AppRadius.rxl,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacingSize.l),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    formatNumber(avgSoil),
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
                        HugeIcon(icon: HugeIcons.strokeRoundedActivity01),
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
                            '$totalPump',
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
                            '$avgDuration',
                            style: TextStyle(
                              fontSize: AppFontSize.xxl,
                              fontWeight: AppFontWeight.semiBold,
                            ),
                          ),
                          Text('Average Duration (s)'),
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
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacingSize.m,
                        ),
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
                            '00:00',
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
                                  builder:
                                      (context) => FractionallySizedBox(
                                        heightFactor: 0.85,
                                        child: Padding(
                                          padding: EdgeInsetsGeometry.symmetric(
                                            horizontal: AppSpacingSize.l,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'All Pump History',
                                                style: TextStyle(
                                                  fontSize: AppFontSize.l,
                                                  fontWeight:
                                                      AppFontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 12),
                                              Expanded(
                                                child: ListView.builder(
                                                  itemCount: pumpLogs.length,
                                                  itemBuilder:
                                                      (context, index) =>
                                                          _PumpHistoryItem(
                                                            pumpLogs[index],
                                                          ),
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

                        SizedBox(height: AppSpacingSize.xs),

                        /// List preview
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: shortList.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder:
                              (context, index) =>
                                  _PumpHistoryItem(shortList[index]),
                        ),
                      ],
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

class _PumpHistoryItem extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PumpHistoryItem(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacingSize.s),
      padding: EdgeInsets.all(AppSpacingSize.m),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.rm),
        border: Border.all(color: AppColors.borderOrange, width: 0.7),
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
              size: AppElementSize.l,
            ),
          ),
          SizedBox(width: AppSpacingSize.m),
          Expanded(
            child: Column(
              spacing: 3,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['user'],
                      style: TextStyle(
                        fontWeight: AppFontWeight.semiBold,
                        fontSize: AppFontSize.s,
                      ),
                    ),
                    Text(
                      '${data['date']}',
                      style: TextStyle(
                        fontSize: AppFontSize.s,
                        color: AppColors.grayMedium,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${data['start']}–${data['end']} (${data['duration']})',
                  style: TextStyle(
                    fontSize: AppFontSize.s,
                    color: AppColors.grayMedium,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: AppFontSize.s,
                      color: AppColors.black,
                    ),
                    children: [
                      TextSpan(
                        text: 'Soil Moisture: ',
                        style: TextStyle(fontSize: AppFontSize.s),
                      ),
                      TextSpan(
                        text: '${data['moistureBefore']}%',
                        style: TextStyle(
                          color: AppColors.danger,
                          fontSize: AppFontSize.s,
                        ),
                      ),
                      TextSpan(
                        text: ' → ',
                        style: TextStyle(fontSize: AppFontSize.s),
                      ),
                      TextSpan(
                        text: '${data['moistureAfter']}%',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: AppFontSize.s,
                        ),
                      ),
                    ],
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
