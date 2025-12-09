import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/media_query_helper.dart';
import '../../infrastructure/local/secure_storage.dart';
import '../providers/auth_provider.dart';
import '../providers/device_provider.dart';
import '../../core/themes/colors.dart';
import '../../core/themes/font_size.dart';
import '../../core/themes/font_weight.dart';
import '../../core/themes/radius_size.dart';
import '../../core/themes/spacing_size.dart';
import '../providers/injection.dart';
import '../widgets/global/app_bar.dart';
import '../widgets/global/dialog.dart';
import '../widgets/global/loading.dart';

  class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfileScreen> {
  bool isLoading = false;
  String? deviceId;

  String profilePictureUrl = '';
  String username = '-';
  String email = '-';
  
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userId = await SecureStorage.getUserId();
      if (userId != null && userId.isNotEmpty) {
        await _loadProfileData(userId);
      }
    });
  }

  Future<void> _loadProfileData(String userId) async {
    setState(() {
      isLoading = true;
    });

    final profileController = ref.read(profileControllerProvider);

    try {
      final result = await profileController.getProfileController(
        userId
      );

      final pprofilePictureUrl = result['profile_picture'];
      final uusername = result['username'];
      final eemail = result['email'];

      if (!mounted) return;

      setState(() {
        profilePictureUrl = pprofilePictureUrl;
        username = uusername;
        email = eemail;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    try {
      setState(() => isLoading = true);

      // 2. Reset device state
      ref.read(deviceProvider.notifier).resetDevices();

      // 3. Logout auth (INI YANG PENTING)
      ref.read(authProvider.notifier).logout();

      if (!mounted) return;

      setState(() => isLoading = false);

      await DialogWidget.showSuccess(
        context: context,
        title: "Logout Success",
        message: "You have been logged out.",
        onOk: () {
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to logout."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showConfirmLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Are you sure you want to logout?",
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                _handleLogout();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQueryHelper.of(context);
    final deviceState = ref.watch(deviceProvider);

    final pairState = deviceState.activePairState;
    
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppSpacingSize.l,
              right: AppSpacingSize.l,
              top: mq.notchHeight * 1.5,
              bottom: AppSpacingSize.l,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        (pairState == null)
                            ? AppBarWidget(
                              type: AppBarType.withoutNotif,
                              title: "Profile",
                            )
                            : AppBarWidget(
                              type: AppBarType.main,
                              title: "Profile",
                            ),

                        SizedBox(height: 24),

                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.all(16),
                                    child: InteractiveViewer(
                                      minScale: 0.8,
                                      maxScale: 4,
                                      child:
                                          profilePictureUrl != null &&
                                                  profilePictureUrl.isNotEmpty
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.rl,
                                                    ),
                                                child: Image.network(
                                                  profilePictureUrl,
                                                  fit: BoxFit.contain,
                                                ),
                                              )
                                              : const Icon(
                                                Icons.person,
                                                size: 120,
                                                color: Colors.white,
                                              ),
                                    ),
                                  ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage:
                                (profilePictureUrl != null &&
                                        profilePictureUrl.isNotEmpty)
                                    ? NetworkImage(profilePictureUrl)
                                    : null,
                            child:
                                (profilePictureUrl == null ||
                                        profilePictureUrl.isEmpty)
                                    ? const Icon(
                                      Icons.person,
                                      size: 48,
                                      color: Colors.grey,
                                    )
                                    : null,
                          ),
                        ),

                        SizedBox(height: 12),

                        Text(
                          username,
                          style: TextStyle(
                            fontSize: AppFontSize.m,
                            fontWeight: AppFontWeight.semiBold
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          email,
                          style: TextStyle(
                            fontSize: AppFontSize.s,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.logout, color: AppColors.danger),
                    label: Text(
                      'Logout',
                      style: TextStyle(color: AppColors.danger),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.danger),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _showConfirmLogoutDialog,
                  ),
                ),
              ],
            ),
          ),

          if (isLoading) LoadingWidget(),
        ],
      ),
    );
  }
}