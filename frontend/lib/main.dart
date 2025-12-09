import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/themes/app_theme.dart';
import 'core/themes/screen_size.dart';
import 'infrastructure/fcm/fcm_background.dart';
import 'infrastructure/local/secure_storage.dart';
import 'infrastructure/local_notification/localnotif_main.dart';
import 'presentation/navigations/main_nav.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/states/auth_state.dart';
import 'presentation/providers/device_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/states/device_state.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await LocalNotificationService.init();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(mainRouterProvider);

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final width = MediaQuery.of(context).size.width;
    ScreenSizeUtil.init(width);

    ref.listen<AsyncValue<AuthState>>(authProvider, (prev, next) async {
      final data = next.valueOrNull;

      // ✅ LOGIN SUKSES
      if (data is AuthAuthenticated) {
        final deviceId = ref.read(deviceProvider).pairedDeviceId;
        

        if (deviceId != null) {
          final notif = ref.read(notificationProvider.notifier);
          final deviceUid = await SecureStorage.getDeviceUId();

          await notif.registerFcmToken(deviceUid);
          await notif.loadNotifications();
        }
      }

      // LOGOUT → MATIKAN SEMUA NOTIF
      if (data is AuthUnauthenticated) {
        final notif = ref.read(notificationProvider.notifier);

        notif.clearAll();
        await LocalNotificationService.cancelAll(); 
      }
    });


    ref.listen<DeviceState>(deviceProvider, (prev, next) async {
      final prevDeviceId = prev?.pairedDeviceId;
      final nextDeviceId = next.pairedDeviceId;

      final notif = ref.read(notificationProvider.notifier);
      

      if (prevDeviceId == null && nextDeviceId != null) {
        final deviceUid = await SecureStorage.getDeviceUId();
        
        await notif.registerFcmToken(deviceUid);
        await notif.loadNotifications();
      }

      if (prevDeviceId != null && nextDeviceId == null) {
        notif.clearAll();
        await LocalNotificationService.cancelAll();
      }
    });


    return ScreenUtilInit(
      designSize: const Size(412, 917),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (_, child) {
        return MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
        );
      },
    );
  }
}
