import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EFC2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🔹 Header: tombol back, judul, logo
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 16, right: 25),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    Image.asset(
                      'lib/assets/images/splash.png',
                      height: 40,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // 🔹 Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 🔹 Profile Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto profil
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFB3E5FC),
                      child: CircleAvatar(
                        radius: 37,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 🔸 Expanded agar teks dan icon bisa menempati seluruh sisa ruang
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bagian nama dan email
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top:
                                      8), // ✅ Tambahkan padding top agar teks turun ke bawah
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Emma Phillips",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "emma@gmail.com",
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 🔸 Icon pencil diposisikan ke pojok kanan
                          GestureDetector(
                            onTap: () {
                              // Aksi ketika icon pencil ditekan
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Edit profile clicked'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Menu Items
              _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: 'Location',
                value: 'Semarang',
              ),
              _buildMenuItem(
                icon: Icons.email_outlined,
                title: 'Change Email Address',
              ),
              _buildMenuItem(
                icon: Icons.notifications_none,
                title: 'Notifications',
              ),
              _buildMenuItem(
                icon: Icons.security_outlined,
                title: 'Security',
              ),

              const SizedBox(height: 10),
              const Divider(thickness: 1),

              // 🔹 Logout
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Log Out",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔸 Widget untuk item menu
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? value,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                value,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: () {},
    );
  }
}
