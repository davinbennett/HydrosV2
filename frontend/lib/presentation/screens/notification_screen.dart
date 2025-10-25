import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _calendarNotifications = false;
  bool _timerNotifications = false;
  bool _appNotifications = false;

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

              // 🔹 Header: Back, Title, Logo
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Notifications",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    'lib/assets/images/splash.png', // 🖼️ Ganti path logo sesuai lokasi kamu
                    height: 40,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // 🔹 Judul Utama
              Padding(
                padding: const EdgeInsets.only(left: 40), // Geser ke kiri agar sejajar dengan header text
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // 🔸 Calendar Notifications
                    _buildNotificationItem(
                      title: "Calendar Notifications",
                      value: _calendarNotifications,
                      onChanged: (val) {
                        setState(() {
                          _calendarNotifications = val;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    // 🔸 Timer Notifications
                    _buildNotificationItem(
                      title: "Timer Notifications",
                      value: _timerNotifications,
                      onChanged: (val) {
                        setState(() {
                          _timerNotifications = val;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    // 🔸 App Notifications
                    _buildNotificationItem(
                      title: "App Notifications",
                      value: _appNotifications,
                      onChanged: (val) {
                        setState(() {
                          _appNotifications = val;
                        });
                      },
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

  // 🔸 Widget pembantu untuk setiap toggle
  Widget _buildNotificationItem({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          "*Panjangnya minimal 12 karakter. Menggunakan huruf besar dan kecil, angka dan simbol khusus.",
          style: TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
