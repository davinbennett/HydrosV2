import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScanDevicePage extends StatelessWidget {
  const ScanDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70, // Turunin semua item AppBar
        leadingWidth: 60,
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              '<',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4), // geser kiri sedikit
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.image, color: Colors.black),
                onPressed: () {},
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12), // geser kiri sedikit
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.flash_on, color: Colors.black),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(250, 250), // ukuran X
                painter: ThinXPainter(),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFD1F7E2), // Warna hijau muda
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // rata tengah
              children: [
                const Center(
                  child: Text(
                    'Enter Code Manually',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.qr_code),
                    hintText: 'Enter Device Code',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7143),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    onPressed: () {
                      // Pair action
                    },
                    child: const Text(
                      'Pair Device',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter untuk membuat X tipis
class ThinXPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2 // garis tipis
      ..strokeCap = StrokeCap.round;

    // Garis miring dari kiri atas ke kanan bawah
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);

    // Garis miring dari kanan atas ke kiri bawah
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
