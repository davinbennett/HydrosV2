import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/font_weight.dart';

class PieChartWidget extends StatelessWidget {
  final double value;
  final Color color;

  const PieChartWidget({super.key, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: color,
                  value: value,
                  title: '',
                  radius: 15,
                ),
                PieChartSectionData(
                  color: AppColors.grayDivider,
                  value: 100 - value,
                  title: '',
                  radius: 15,
                ),
              ],
              centerSpaceRadius: 30,
              sectionsSpace: 0,
              centerSpaceColor: Colors.white,
              startDegreeOffset: -90,
            ),
          ),
          Text(
            value == 0 ? "-- %" : "${value.toStringAsFixed(0)}%",
            style: TextStyle(
              fontWeight: AppFontWeight.semiBold,
            ),
          ),
        ]
      ),
    );
  }
}
