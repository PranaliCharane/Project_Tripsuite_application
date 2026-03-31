import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tripsuite_app_boilerplate/features/auth/login_screen.dart';
import 'package:tripsuite_app_boilerplate/features/auth/services/auth_service.dart';
import 'package:tripsuite_app_boilerplate/features/profile/providers/profile_image_provider.dart';
import 'package:tripsuite_app_boilerplate/features/profile/screens/account_settings_screen.dart';
import 'package:tripsuite_app_boilerplate/features/profile/screens/help_support_screen.dart';
import 'package:tripsuite_app_boilerplate/features/profile/screens/widgets/profile_menu_tile.dart';
import 'package:tripsuite_app_boilerplate/features/profile/screens/widgets/profile_stat_item.dart';
import 'package:tripsuite_app_boilerplate/helper/app_gradients.dart';
import 'package:tripsuite_app_boilerplate/core/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickProfileImage() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null) {
        await context
            .read<ProfileImageProvider>()
            .updateProfileImage(File(picked.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update profile image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  ImageProvider _buildProfileImage() {
    final imageFile = context.watch<ProfileImageProvider>().imageFile;
    if (imageFile != null) {
      return FileImage(imageFile);
    }
    return const AssetImage("assets/images/host_avatar.png");
  }

  Widget _buildGradientHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: CircleAvatar(
              radius: 52,
              backgroundColor: Colors.white54,
              backgroundImage: _buildProfileImage(),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF379DD3),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Pranali Charane",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Superhost · pranali@gmail.com",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: const Text(
              "Trust & Safety Verified",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? trailing, VoidCallback? onTrailingTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          if (trailing != null && onTrailingTap != null)
            TextButton(
              onPressed: onTrailingTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                trailing,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF379DD3),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return Scaffold(
      backgroundColor: AppColors.lightgreySecond,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildGradientHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
            _buildSectionTitle("Stats"),
                  _buildCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        ProfileStatItem(title: "Trips", value: "12"),
                        ProfileStatItem(title: "Reviews", value: "8"),
                        ProfileStatItem(title: "Months on Airbnb", value: "6"),
                      ],
                    ),
                  ),
          _buildSectionTitle("Account"),
          _buildCard(
                    child: Column(
                      children: [
                        ProfileMenuTile(
                          icon: Icons.settings,
                          title: "Account Settings",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AccountSettingsScreen(),
                              ),
                            );
                          },
                        ),
                        ProfileMenuTile(
                          icon: Icons.help_outline,
                          title: "Get Help",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                            );
                          },
                        ),
                        ProfileMenuTile(
                          icon: Icons.logout,
                          title: "Log Out",
                          color: Colors.red,
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Log out'),
                                  content: const Text('Are you sure you want to log out?'),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(80, 40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text('No'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        minimumSize: const Size(80, 40),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          side: const BorderSide(color: AppColors.blue),
                                        ),
                                        foregroundColor: AppColors.blue,
                                      ),
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirmed == true) {
                              await authService.signOut();
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,
                                );
                              }
                            }
                          },
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
    );
  }
}
