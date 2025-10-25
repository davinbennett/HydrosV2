import 'package:flutter/material.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool _isLocationEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EFC2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Turunkan sedikit header
              const SizedBox(height: 20),

              // 🔹 Baris atas: back, title, dan logo
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Location",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    'lib/assets/images/splash.png',
                    height: 40,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // 🔹 Bagian isi: digeser sedikit ke kiri
              Padding(
                padding: const EdgeInsets.only(left: 40), // ⬅️ sebelumnya 50, kini lebih ke kiri
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Location",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Location",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Switch(
                          value: _isLocationEnabled,
                          onChanged: (value) {
                            setState(() {
                              _isLocationEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "*Panjangnya minimal 12 karakter. Menggunakan huruf besar dan kecil, angka dan simbol khusus.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
