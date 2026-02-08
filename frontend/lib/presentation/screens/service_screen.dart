import 'package:flutter/material.dart';

class DeviceControlPage extends StatefulWidget {
  const DeviceControlPage({super.key});

  @override
  State<DeviceControlPage> createState() => _DeviceControlPageState();
}

class _DeviceControlPageState extends State<DeviceControlPage> {
  bool _pumpOn = false;
  RangeValues _moistureRange = const RangeValues(2, 8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EFC2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('lib/assets/images/splash.png', height: 60),
                    const Text(
                      "Services",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const Icon(Icons.notifications_none, size: 28),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 🔸 Quick Activity Section
              Row(
                children: const [
                  Icon(Icons.receipt_long_outlined, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    "Quick Activity",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ActivityRow(
                      icon: Icons.water_drop_outlined,
                      title: "Last Pumped",
                      value: "Jul 5’25  at 14:00:00",
                    ),
                    SizedBox(height: 18),
                    ActivityRow(
                      icon: Icons.thermostat_outlined,
                      title: "Moisture Range",
                      value: "Min: 2%   |   Max: 8%",
                    ),
                    SizedBox(height: 18),
                    ActivityRow(
                      icon: Icons.alarm,
                      title: "Next Alarm Pump",
                      value: "Jul 5’25  at 14:00:00",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),

              // 🔸 Device Control Section
              Row(
                children: const [
                  Icon(Icons.settings_remote_outlined, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    "Device Control",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 🔹 Pump + Soil Setting
              Row(
                children: [
                  // 🔹 Pump Card
                  Expanded(
                    child: Container(
                      height: 200,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.water_drop_outlined, size: 36),
                              Switch(
                                value: _pumpOn,
                                onChanged: (val) {
                                  setState(() => _pumpOn = val);
                                },
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Text(
                            "Pump",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _pumpOn ? "On" : "Off",
                            style: TextStyle(
                              color: _pumpOn ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 🔹 Soil Setting Card
                  Expanded(
                    child: Container(
                      height: 200,
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // 🔹 Judul
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.water_drop_outlined, size: 30),
                              SizedBox(width: 6),
                              Text(
                                "Soil Setting",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32), // 🔼 tambah jarak dari judul ke angka

                          // 🔹 Label + Slider
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Angka di atas titik
                              Positioned(
                                left: 30,
                                top: -22, // posisinya tidak terlalu tinggi
                                child: labelBox(2),
                              ),
                              Positioned(
                                right: 30,
                                top: -22,
                                child: labelBox(8),
                              ),
                              RangeSlider(
                                values: _moistureRange,
                                min: 0,
                                max: 10,
                                divisions: 10,
                                onChanged: (RangeValues values) {
                                  setState(() => _moistureRange = values);
                                },
                                activeColor: Colors.deepOrangeAccent,
                                inactiveColor: Colors.orange.shade100,
                              ),
                            ],
                          ),

                          const SizedBox(height: 10), // 🔼 teks dinaikkan sedikit

                          // 🔹 Deskripsi teks
                          Text(
                            "Set soil moisture range for auto irrigation",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              height: 1.2,
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // ✅ Alarm section
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Alarm in 2 days 17 hours 32 minutes",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(thickness: 0.8),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Icon(Icons.alarm, size: 30),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            "Alarm\nSchedule pump with alarm",
                            style: TextStyle(fontSize: 14, height: 1.3),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // 🔸 Label angka di atas slider
  static Widget labelBox(int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.deepOrangeAccent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// 🔸 Widget ActivityRow
class ActivityRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ActivityRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.black54, fontSize: 13),
        ),
      ],
    );
  }
} 
