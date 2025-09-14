import 'package:flutter/material.dart';
import 'package:frontend/core/themes/element_size.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/themes/font_weight.dart';
import 'package:frontend/core/themes/spacing_size.dart';
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
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacingSize.l),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('lib/assets/images/logo_hydros.png', height: 45),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppFontSize.l,
                  fontWeight: AppFontWeight.semiBold,
                ),
              ),
              GestureDetector(
                onTap: onNotificationTap ?? () {},
                child: Icon(Icons.notifications_none_outlined, size: AppElementSize.m),
              ),
            ],
          ),
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
