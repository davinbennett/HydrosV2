import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/themes/app_theme.dart';
import 'package:frontend/core/themes/screen_size.dart';
import 'package:frontend/core/utils/logger.dart';
import 'presentation/navigations/main_nav.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final apiKey = dotenv.env['API_KEY'] ?? '';
  final appId = dotenv.env['APP_ID'] ?? '';
  final messagingSenderId = dotenv.env['MESSAGING_SENDER_ID'] ?? '';
  final projectId = dotenv.env['PROJECT_ID'] ?? '';

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
    ),
  );

  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      logger.i('User is currently signed out!');
    } else {
      logger.i('User is signed in!');
    }
  });

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(mainRouterProvider);

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final width = MediaQuery.of(context).size.width;
    ScreenSizeUtil.init(width);

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
