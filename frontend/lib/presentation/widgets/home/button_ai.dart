import 'package:flutter/material.dart';
import 'package:frontend/core/themes/element_size.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/themes/font_weight.dart';

class ButtonAiWidget extends StatelessWidget {
  final String text;
  final IconData? icon;

  final String? pngAsset;

  final VoidCallback onPressed;
  final double borderRadius;
  final bool isOutlined;

  const ButtonAiWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.pngAsset,
    this.borderRadius = 1000.0,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontWeight: AppFontWeight.semiBold,
        fontSize: AppFontSize.m,
      ),
    );

    final iconWidget =
        icon != null
            ? Icon(icon, size: AppElementSize.m, color: Colors.white)
            : (pngAsset != null
                ? Image.asset(
                  pngAsset!,
                  width: AppElementSize.m,
                  height: AppElementSize.m,
                  fit: BoxFit.contain,
                )
                : null);

    final child =
        iconWidget == null
            ? textWidget
            : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconWidget,
                SizedBox(width: AppSpacingSize.s),
                textWidget,
              ],
            );

    final padding = EdgeInsets.symmetric(
      vertical: AppSpacingSize.m,
      horizontal: AppSpacingSize.l,
    );

    final gradient = const LinearGradient(
      colors: [
        Color(0xFF548CC9),
        Color(0xFF5682C3),
        Color(0xFF7B7AB6),
        Color(0xFFCF646C),
      ],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    );

    if (isOutlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF548CC9), width: 1),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Container(
            padding: padding,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
