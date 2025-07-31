import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/core/themes/element_size.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/themes/font_weight.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final IconData? icon;
  final SvgPicture? svgAsset;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool isOutlined;

  const ButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.svgAsset,
    this.backgroundColor = AppColors.orange,
    this.foregroundColor = Colors.white,
    this.borderColor,
    this.borderRadius = 1000.0,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      style: TextStyle(
        color: foregroundColor,
        fontWeight: AppFontWeight.medium,
        fontSize: AppFontSize.m
      ),
    );

    final iconWidget =
        icon != null
            ? Icon(icon, size: AppElementSize.m, color: foregroundColor)
            : svgAsset;

    final child =
        iconWidget == null
            ? textWidget
            : Row(
              mainAxisSize: MainAxisSize.min,
              children: [iconWidget, SizedBox(width: AppSpacingSize.s), textWidget],
            );

    final padding = EdgeInsets.symmetric(
      vertical: AppSpacingSize.m, 
      horizontal: AppSpacingSize.l
    );

    return SizedBox(
      width: double.infinity,
      child:
          isOutlined
              ? OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  padding: padding,
                  backgroundColor: backgroundColor,
                  side: BorderSide(
                    color: borderColor ?? AppColors.grayLight,
                    width: 0.7,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                child: child,
              )
              : ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  foregroundColor: foregroundColor,
                  padding: padding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                child: child,
              ),
    );
  }
}
