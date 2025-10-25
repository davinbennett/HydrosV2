import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController =
      TextEditingController(text: "Oh Sehun");
  final TextEditingController _birthController =
      TextEditingController(text: "11/07/2006");
  final TextEditingController _phoneController =
      TextEditingController(text: "+62");
  String _gender = "Male";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3C7), // warna krem lembut
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40), // 🔽 jarak dari atas

                  // 🔹 Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            "Edit Profile",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Image.asset(
                        'lib/assets/images/splash.png', // logo Hydros
                        height: 45,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // 🔹 Foto profil
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.teal.shade200,
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Upload Photo",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 🔹 Name
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Name",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black26),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Birth Date & Gender
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Birth Date",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextField(
                              controller: _birthController,
                              decoration: const InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black26),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Gender",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              height: 48,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.black26),
                                ),
                              ),
                              child: DropdownButton<String>(
                                value: _gender,
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(
                                    value: "Male",
                                    child: Text("Male"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Female",
                                    child: Text("Female"),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _gender = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Mobile Phone
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Mobile Phone",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black26),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 🔹 Tombol Cancel & Save (dibalik + pakai button)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tombol Cancel
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Tombol Save
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Profile saved successfully!"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
