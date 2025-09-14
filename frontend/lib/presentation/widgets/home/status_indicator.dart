import 'package:flutter/material.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/themes/font_weight.dart';

enum StatusType { humidity, soil }

class StatusIndicatorWidget extends StatelessWidget {
  final StatusType type;
  final double value;
  final double? min;
  final double? max;

  const StatusIndicatorWidget({
    super.key,
    required this.type,
    required this.value,
    this.min,
    this.max,
  });

  Color _getColor() {
    switch (type) {
      case StatusType.humidity:
        if (value < 20) return AppColors.danger;
        if (value >= 20 && value < 40) return AppColors.warning;
        if (value >= 40 && value <= 60) return AppColors.success;
        if (value > 60 && value <= 80) return AppColors.warning;
        return AppColors.danger;

      case StatusType.soil:
        if (value >= min! && value <= max!) {
          return AppColors.success;
        } else if (value < min!) {
          double ratio = (min! - value) / min!;
          return ratio > 0.5 ? AppColors.danger : AppColors.warning;
        } else {
          double threshold = (100 - max!) * 0.5;
          return value > max! + threshold
              ? AppColors.danger
              : AppColors.warning;
        }
    }
  }

  String _getText() {
    switch (type) {
      case StatusType.humidity:
        if (value < 20) return "Too Dry!";
        if (value >= 20 && value < 40) return "Getting Dry";
        if (value >= 40 && value <= 60) return "Ideal";
        if (value > 60 && value <= 80) return "Getting Humid";
        return "Too Humid!";

      case StatusType.soil:
        if (min == null || max == null) return "-";

        if (value >= min! && value <= max!) {
          return "Ideal";
        } else if (value < min!) {
          double threshold = min! * 0.5;
          return value < threshold ? "Too Dry!" : "Getting Dry";
        } else {
          double threshold = (100 - max!) * 0.5;
          return value > max! + threshold ? "Too Wet!" : "Getting Wet";
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: _getColor()),
        ),
        SizedBox(width: 6),
        Text(
          _getText(),
          style: TextStyle(
            fontSize: AppFontSize.s,
            fontWeight: AppFontWeight.medium,
          ),
        ),
      ],
    );
  }
}
