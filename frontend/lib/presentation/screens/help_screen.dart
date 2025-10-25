import 'package:flutter/material.dart';

class HelpAboutPairDevicePage extends StatelessWidget {
  const HelpAboutPairDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5DC), // krem muda
      body: SafeArea(
        child: Column(
          children: [
            // TOP APPBAR CUSTOM
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  const SizedBox(height: 25), // ⬅️ Turunkan appbar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Help About Pair Device',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Image.asset(
                        'lib/assets/images/splash.png', // logo kanan
                        height: 52,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bagian konten utama diturunkan ke tengah layar
            Expanded(
              child: Column(
                children: [
                  const Spacer(), // ⬅️ Dorong ke bawah
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Gambar utama
                        Image.asset(
                          'lib/assets/images/pair_device.png',
                          height: 180,
                        ),
                        const SizedBox(height: 24),

                        // Paragraf teks
                        const Text(
                          "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. "
                          "The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, "
                          "as opposed to using 'Content here, content here', making it look like readable English.",
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Dua ikon + teks
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Image.asset(
                                  'lib/assets/images/pair_device.png',
                                  height: 90,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '1. Search Your Barcode',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Image.asset(
                                  'lib/assets/images/pair_device.png',
                                  height: 90,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '2. Scan with Phone',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                  const Spacer(flex: 20), // ⬅️ Tambah ruang bawah
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
