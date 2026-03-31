import 'package:flutter/material.dart';
import 'package:tripsuite_app_boilerplate/core/theme/app_theme.dart';
import 'package:tripsuite_app_boilerplate/features/profile/screens/widgets/settings_tile.dart';
import 'personal_information_screen.dart';
import 'login_security_screen.dart';
import 'notifications_screen.dart';
import 'payments_screen.dart';
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightgreySecond,
      appBar: AppBar(
        title: const Text("Account Settings"),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          SettingsTile(
            icon: Icons.person_outline,
            title: "Personal information",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PersonalInformationScreen(),
                ),
              );
            },
          ),

          SettingsTile(
            icon: Icons.lock_outline,
            title: "Login & security",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginSecurityScreen(),
                ),
              );
            },
          ),

          SettingsTile(
            icon: Icons.notifications_outlined,
            title: "Notifications",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),

          SettingsTile(
            icon: Icons.payment_outlined,
            title: "Payments",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PaymentsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
