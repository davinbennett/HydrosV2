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
                    SizedBox(height: 150),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kiri: info lokasi + suhu
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 18, color: Colors.black),
                                    SizedBox(width: 4),
                                    Text('-', style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 4,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '°C',
                                      style: TextStyle(
                                        fontSize: 24, // atau AppFontSize.xl
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text('-', style: TextStyle(fontSize: 14)),
                              ],
                            ),

                            // Kanan: gambar petani
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50), // bulat seperti desain kamu
                              child: Image.asset(
                                'assets/farmer.png', // ganti dengan path gambar kamu
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
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
