import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/themes/spacing_size.dart';
import '../../core/utils/media_query_helper.dart';
import '../providers/device_provider.dart';
import '../widgets/global/app_bar.dart';
import '../widgets/global/button.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final mq = MediaQueryHelper.of(context);
    final deviceState = ref.watch(deviceProvider);
    final pairState = deviceState.activePairState;
    final deviceId = deviceState.pairedDeviceId;

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
              AppBarWidget(title: 'History', type: AppBarType.withoutNotif,),
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
      body: SingleChildScrollView(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: AppSpacingSize.l,
            right: AppSpacingSize.l,
            top: mq.notchHeight * 1.5,
          ),
          child: Column(
            children: [
              AppBarWidget(title: 'History', type: AppBarType.main),
              Text(
                'Device ID: $deviceId',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
}