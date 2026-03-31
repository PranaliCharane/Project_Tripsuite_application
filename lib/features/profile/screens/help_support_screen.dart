import 'package:flutter/material.dart';
import 'package:tripsuite_app_boilerplate/core/theme/app_theme.dart';
import 'package:tripsuite_app_boilerplate/helper/app_gradients.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  final List<Map<String, String>> _faqItems = const [
    {
      'question': 'How do I change my booking dates?',
      'answer':
          'Go to your trip itinerary, tap "Modify trip", and submit a change request. Approval takes under 1 business day.',
    },
    {
      'question': 'How do I view my receipts?',
      'answer':
          'Open the Payments tab, tap "View all receipts", and download or share the PDF for any booking.',
    },
    {
      'question': 'How can I share expenses with others?',
      'answer':
          'In the trip details screen, add members and create shared expenses. Each person can log contributions.',
    },
    {
      'question': 'What should I do if my payment fails?',
      'answer':
          'Try another saved card or add a new one via the Payments screen. If failures persist, contact support.',
    },
  ];

  Widget _infoCard({
    required String title,
    required String subtitle,
    String? trailing,
    VoidCallback? onTap,
    bool isCritical = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: trailing != null
            ? Text(
                trailing,
                style: TextStyle(
                  color: isCritical ? AppColors.accent : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final helpTopics = [
      'Manage bookings and check-in',
      'Understand charges & receipts',
      'Share trip expenses',
      'Security & account recovery',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.lightgreySecond,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient55deg,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Need help with TripSuite?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'We can guide you through bookings, payments, and safety anytime.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          _sectionTitle('Quick actions'),
          _infoCard(
            title: 'Contact support',
            subtitle: 'Chat live with our travel team',
            trailing: 'Chat now',
            onTap: () {},
          ),
          _infoCard(
            title: 'Call support',
            subtitle: 'Available 24/7 · +91 800 555 0102',
            trailing: 'Call',
            onTap: () {},
          ),
          _infoCard(
            title: 'Report a traveler or host',
            subtitle: 'Urgent safety escalations',
            trailing: 'Report',
            isCritical: true,
            onTap: () {},
          ),

          _sectionTitle('Common questions'),
          ..._faqItems.map((faq) => ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  faq['question']!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                children: [
                  Text(faq['answer']!),
                ],
              )),

          _sectionTitle('App updates'),
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'What’s new in TripSuite',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text('Get notified about new travel insurance waivers, split bills improvements, and policy updates.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
