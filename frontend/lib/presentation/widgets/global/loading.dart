import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final bool visible;
  final Color backgroundColor;
  final double opacity;
  final Color indicatorColor;
  final double size;

  const LoadingWidget({
    super.key,
    this.visible = true,
    this.backgroundColor = Colors.black,
    this.opacity = 0.55,
    this.indicatorColor = Colors.white,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Container(
      color: backgroundColor.withOpacity(opacity),
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            color: indicatorColor,
          ),
        ),
      ),
    );
  }
}
