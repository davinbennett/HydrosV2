import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/themes/element_size.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/themes/font_weight.dart';
import 'package:frontend/core/themes/spacing_size.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/colors.dart';
import '../../providers/websocket/device_status_provider.dart';

enum AppBarType { main, back, withoutNotif }

class AppBarWidget extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceStatusProvider);

    Color statusColor;
    switch (Timer.periodic.status?.toLowerCase()) {
      case 'stable':
        statusColor = AppColors.success;
        break;
      default:
        statusColor = AppColors.danger;
        break;
    }
    
    switch (type) {
      case AppBarType.main:
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacingSize.l),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'lib/assets/images/logo_hydros.png',
                  height: 45,
                ),
              ),
              Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AppFontSize.l,
                    fontWeight: AppFontWeight.semiBold,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    // 🔴🟢 Status indicator
                    Container(
                      width: 17,
                      height: 17,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.15,
                            ), 
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 0.5)
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacingSize.s),
                    GestureDetector(
                      onTap: onNotificationTap ?? () {},
                      child: Icon(
                        Icons.notifications_none_outlined,
                        size: AppElementSize.m,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case AppBarType.withoutNotif:
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacingSize.l),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'lib/assets/images/logo_hydros.png',
                  height: 45,
                ),
              ),
              Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AppFontSize.l,
                    fontWeight: AppFontWeight.semiBold,
                  ),
                ),
              ),
            ],
          ),
        );

      case AppBarType.back:
        return Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onBack ?? () => context.pop(),
                  child: Icon(Icons.arrow_back, size: AppElementSize.m),
                ),
                SizedBox(width: AppElementSize.m),
              ],
            ),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppFontSize.l,
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
          ],
        );
    }
  }
}
