import 'package:flutter/material.dart';
import 'package:frontend/core/themes/element_size.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/themes/font_weight.dart';
import 'package:go_router/go_router.dart';

enum AppBarType { main, back }

class AppBarWidget extends StatelessWidget {
  final AppBarType type;
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onNotificationTap;

  const AppBarWidget({
    super.key,
    required this.type,
    required this.title,
    this.onBack,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AppBarType.main:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('lib/assets/images/logo_hydros.png', height: 32),
            Text(
              title,
              style: TextStyle(
                fontSize: AppFontSize.l,
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
            GestureDetector(
              onTap: onNotificationTap ?? () {},
              child: Icon(Icons.notifications, size: AppElementSize.m),
            ),
          ],
        );

      case AppBarType.back:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onBack ?? () => context.pop(),
              child: Icon(Icons.arrow_back, size: AppElementSize.m),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: AppFontSize.l,
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
            SizedBox(width: AppElementSize.m), // spacer biar rata
          ],
        );
    }
  }
}
