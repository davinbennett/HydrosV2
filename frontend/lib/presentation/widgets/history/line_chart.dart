import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/themes/font_weight.dart';
import 'package:frontend/core/themes/radius_size.dart';
import 'package:frontend/core/themes/spacing_size.dart';

class LineChartWidget extends StatefulWidget {
  const LineChartWidget({
    super.key,
    required this.data,
    this.title = 'Chart',
    this.minY,
    this.maxY,
    this.bottomLabels,
    this.yLabel = 'Count',
    this.gradientColor1 = AppColors.blue,
    this.gradientColor2 = AppColors.danger,
    this.indicatorStrokeColor = AppColors.black,
  });

  /// Titik data grafik
  final List<FlSpot> data;

  /// Label untuk sumbu bawah (misal waktu)
  final List<String>? bottomLabels;

  /// Judul grafik
  final String title;

  /// Label sumbu Y
  final String yLabel;

  /// Nilai minimal & maksimal (auto jika null)
  final double? minY;
  final double? maxY;

  /// Warna gradien
  final Color gradientColor1;
  final Color gradientColor2;
  final Color indicatorStrokeColor;

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  List<int> showingTooltipOnSpots = [];

  Widget _bottomTitle(double value, TitleMeta meta, double chartWidth) {
    final style = TextStyle(
      fontWeight: AppFontWeight.semiBold,
      color: AppColors.success,
      fontSize: 16 * chartWidth / 500,
    );

    // ambil label sesuai index
    String text = '';
    if (widget.bottomLabels != null) {
      final index = value.toInt();
      if (index >= 0 && index < widget.bottomLabels!.length) {
        text = widget.bottomLabels![index];
      }
    }

    if (text.isEmpty) return const SizedBox.shrink();
    return SideTitleWidget(meta: meta, child: Text(text, style: style));
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final minY =
        widget.minY ?? data.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY =
        widget.maxY ?? data.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: data,
        isCurved: true,
        barWidth: 5,
        shadow: const Shadow(blurRadius: 0.5),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              widget.gradientColor1.withValues(alpha: 0.4),
              widget.gradientColor2.withValues(alpha: 0.8),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        dotData: const FlDotData(show: true),
        gradient: LinearGradient(
          colors: [widget.gradientColor1, widget.gradientColor2],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacingSize.m),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return LineChart(
              LineChartData(
                showingTooltipIndicators:
                    showingTooltipOnSpots.map((index) {
                      return ShowingTooltipIndicators([
                        LineBarSpot(
                          tooltipsOnBar,
                          0,
                          tooltipsOnBar.spots[index],
                        ),
                      ]);
                    }).toList(),
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  touchCallback: (
                    FlTouchEvent event,
                    LineTouchResponse? response,
                  ) {
                    if (response == null || response.lineBarSpots == null)
                      return;
                    if (event is FlTapUpEvent) {
                      final spotIndex = response.lineBarSpots!.first.spotIndex;
                      setState(() {
                        if (showingTooltipOnSpots.contains(spotIndex)) {
                          showingTooltipOnSpots.remove(spotIndex);
                        } else {
                          showingTooltipOnSpots.add(spotIndex);
                        }
                      });
                    }
                  },
                  getTouchedSpotIndicator: (barData, indexes) {
                    return indexes.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(color: AppColors.grayMedium),
                        FlDotData(
                          show: true,
                          getDotPainter:
                              (spot, percent, bar, index) => FlDotCirclePainter(
                                radius: 7,
                                color: AppColors.success,
                                strokeWidth: 1.5,
                                strokeColor: widget.indicatorStrokeColor,
                              ),
                        ),
                      );
                    }).toList();
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.success,
                    tooltipBorderRadius: BorderRadius.circular(AppRadius.rfull),
                    getTooltipItems:
                        (spots) =>
                            spots
                                .map(
                                  (e) => LineTooltipItem(
                                    e.y.toStringAsFixed(1),
                                    TextStyle(
                                      color: Colors.white,
                                      fontWeight: AppFontWeight.semiBold,
                                      fontSize: AppFontSize.s,
                                    ),
                                  ),
                                )
                                .toList(),
                  ),
                ),
                lineBarsData: lineBarsData,
                minY: minY - 1,
                maxY: maxY + 1,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(widget.yLabel),
                    axisNameSize: AppFontSize.xl,
                    sideTitles: const SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 32,
                      getTitlesWidget:
                          (v, m) => _bottomTitle(v, m, constraints.maxWidth),
                    ),
                  ),
                  topTitles: AxisTitles(
                    axisNameWidget: Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: AppFontSize.l,
                          fontWeight: AppFontWeight.semiBold,
                        ),
                      ),
                    ),
                    axisNameSize: 42,
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
              ),
            );
          },
        ),
      ),
    );
  }
}
