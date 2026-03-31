import 'package:flutter/material.dart';
import 'package:tripsuite_app_boilerplate/core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<String> _filters = ['All', 'Trips', 'Payments', 'Wishlist'];
  String _activeFilter = 'All';
  final Map<String, bool> _channelToggles = {
    'Push': true,
    'Email': true,
    'SMS': false,
  };

  final List<Map<String, String>> _notifications = [
    {
      'title': 'Trip itinerary confirmed',
      'subtitle': 'Maldives Escape · Jan 15',
      'category': 'Trips',
      'time': '2h ago'
    },
    {
      'title': 'New expense shared with you',
      'subtitle': 'Rupack Cafe · ₹1,200',
      'category': 'Payments',
      'time': '4h ago'
    },
    {
      'title': 'Upcoming check-in reminder',
      'subtitle': 'Goa Retreat · Tomorrow 10:00 AM',
      'category': 'Trips',
      'time': 'Yesterday'
    },
    {
      'title': 'Wishlist price drop',
      'subtitle': 'Sky Loft Suite is now ₹6,400/night',
      'category': 'Wishlist',
      'time': '2 days ago'
    },
    {
      'title': 'Payment failed',
      'subtitle': 'Visa ending 5168 · Try another card',
      'category': 'Payments',
      'time': '3 days ago'
    },
  ];

  List<Map<String, String>> get _filteredNotifications {
    if (_activeFilter == 'All') return _notifications;
    return _notifications.where((note) => note['category'] == _activeFilter).toList();
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildChip(String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _activeFilter == label,
      onSelected: (selected) {
        setState(() {
          _activeFilter = label;
        });
      },
    );
  }

  Widget _buildNotificationCard(Map<String, String> note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(note['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${note['subtitle']} · ${note['time']}'),
        trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
        leading: CircleAvatar(
          backgroundColor: AppColors.lightgrey,
          child: Text(note['category']![0]),
        ),
      ),
    );
  }

  Widget _buildChannelToggle(String label) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      value: _channelToggles[label] ?? false,
      onChanged: (value) {
        setState(() {
          _channelToggles[label] = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.lightgreySecond,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _sectionTitle('Notification channels'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: _channelToggles
                  .entries
                  .map((entry) => Column(
                        children: [
                          _buildChannelToggle(entry.key),
                          if (entry.key != _channelToggles.keys.last) const Divider(),
                        ],
                      ))
                  .toList(),
            ),
          ),
          _sectionTitle('Filter by'),
          Wrap(
            spacing: 8,
            children: _filters.map(_buildChip).toList(),
          ),
          _sectionTitle('Recent alerts'),
          for (var note in _filteredNotifications) _buildNotificationCard(note),
        ],
      ),
    );
  }
}
