import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/themes/colors.dart';
import 'package:frontend/core/themes/font_size.dart';
import 'package:frontend/core/themes/font_weight.dart';
import 'package:frontend/core/themes/spacing_size.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeScreenHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.secondary,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.secondary,
        ), //box decoration
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: safeScreenHeight),
              child: Form(
                child: Column(
                  children: [
                    // ! TOP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.translate(
                            offset: Offset(40, 60), // Geser teks turun sejajar tombol
                            child: Text(
                              'Hi, Hydromers!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: AppFontSize.xl,
                                fontWeight: AppFontWeight.semiBold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(width: 50), // Spasi antara teks dan tombol
                        GestureDetector(
                          onTap: () {
                            // aksi ketika tombol ditekan
                          },
                          child: Transform.translate(
                            offset: Offset(45, 60),
                              child: Icon(
                                Icons.notifications_none,
                                color: Colors.black,
                                size: 24,
                              ),
                          ),
                        ),    
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hi, Hydromers!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFontSize.xl,
                            fontWeight: AppFontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Hi, Hydromers!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFontSize.xl,
                            fontWeight: AppFontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Hi, Hydromers!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFontSize.xl,
                            fontWeight: AppFontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hi, Hydromers!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFontSize.xl,
                            fontWeight: AppFontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Hi, Hydromers!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFontSize.xl,
                            fontWeight: AppFontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Hi, Hydromers!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: AppFontSize.xl,
                            fontWeight: AppFontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
