import 'package:flutter/material.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  // nilai default RangeSlider
  RangeValues _pumpRange = const RangeValues(2, 8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5DC), // krem muda
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70), // lebih kecil
        child: AppBar(
          backgroundColor: const Color(0xFFFDF5DC),
          elevation: 0,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(top: 15, left: 12),
            child: Image.asset('lib/assets/images/splash.png'),
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 15),
            child: Text(
              "Services",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(top: 15, right: 12),
              child: IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Jarak kiri kanan
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QUICK ACTIVITY
            Row(
              children: const [
                Icon(Icons.flash_on, color: Colors.black54, size: 18),
                SizedBox(width: 6),
                Text(
                  "Quick Activity",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4), // margin antar card
              padding: const EdgeInsets.all(12),
              decoration: _boxDecoration(),
              child: Column(
                children: [
                  _quickActivityRow(
                    Icons.water_drop,
                    "Last Pumped",
                    "Jul 5' 25 at 14:00:00",
                  ),
                  const Divider(),
                  _quickActivityRow(
                    Icons.grass,
                    "Moisture Range",
                    "Min: 2% | Max: 8%",
                  ),
                  const Divider(),
                  _quickActivityRow(
                    Icons.alarm,
                    "Next Alarm Pump",
                    "Jul 5' 25 at 14:00:00",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // DEVICE CONTROL
            Row(
              children: const [
                Icon(Icons.settings, color: Colors.black54, size: 18),
                SizedBox(width: 6),
                Text(
                  "Device Control",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _deviceCard("Pump", false)),
                const SizedBox(width: 12),
                Expanded(
                  child: _deviceCard(
                    "Pump",
                    true,
                    rangeValues: _pumpRange,
                    onChanged: (values) {
                      setState(() {
                        _pumpRange = values;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ALARM
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: _boxDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Alarm in 2 days 17 hours 32 minutes",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Divider(),
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.access_alarm,
                      size: 32, // diperbesar biar seimbang
                      color: Colors.black87,
                    ),
                    title: const Text("Alarm", style: TextStyle(fontSize: 14)),
                    subtitle: const Text("Schedule pump with alarm",
                        style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Box style biar konsisten
  static BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Row untuk Quick Activity
  static Widget _quickActivityRow(IconData icon, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.black54, size: 18),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  // Kartu Device
  static Widget _deviceCard(
    String title,
    bool withSlider, {
    RangeValues? rangeValues,
    Function(RangeValues)? onChanged,
  }) {
    return SizedBox(
      height: 180,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4), // jarak antar card
        padding: const EdgeInsets.all(12),
        decoration: _boxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.settings_input_component, size: 28),
                Switch(value: false, onChanged: (val) {}),
              ],
            ),
            if (withSlider && rangeValues != null)
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 10),
                  valueIndicatorShape:
                      const PaddleSliderValueIndicatorShape(),
                  valueIndicatorColor: Colors.orange,
                  showValueIndicator: ShowValueIndicator.always,
                ),
                child: RangeSlider(
                  values: rangeValues,
                  min: 0,
                  max: 10,
                  divisions: 10,
                  activeColor: Colors.orange,
                  inactiveColor: Colors.orange.shade100,
                  onChanged: onChanged,
                  labels: RangeLabels(
                    rangeValues.start.round().toString(),
                    rangeValues.end.round().toString(),
                  ),
                ),
              ),
            Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const Text("Off",
                    style: TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
