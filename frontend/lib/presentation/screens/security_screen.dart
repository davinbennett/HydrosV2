import 'package:flutter/material.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _usePassword = false;

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
              const SizedBox(height: 20),

              // 🔹 Header: Back, Title, Logo Hydros
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Security",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    'lib/assets/images/splash.png', // 🖼️ Path logo Hydros
                    height: 40,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // 🔹 Judul utama
              Padding(
                padding: const EdgeInsets.only(left: 40), // agar sejajar dengan teks header
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Security",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // 🔸 Use Password Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Use Password",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Switch(
                          value: _usePassword,
                          onChanged: (val) {
                            setState(() {
                              _usePassword = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "*Panjangnya minimal 12 karakter. Menggunakan huruf besar dan kecil, angka dan simbol khusus.",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),

                    const SizedBox(height: 25),

                    // 🔸 Change Password Section
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Change Password",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
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
            ],
          ),
        ),
      ),
    );
  }
}
