import 'package:flutter/material.dart';
import 'package:tripsuite_app_boilerplate/core/theme/app_theme.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final Map<String, String> _values = {
    'displayName': 'Pranali Charane',
    'email': 'pranali@gmail.com',
    'phone': '+91 12345 67890',
    'location': 'Pune, India',
    'language': 'English',
    'currency': 'INR (₹)',
    'linked': 'Google, Apple',
    'marketing': 'Email · SMS',
    'discoverability': 'Profile visible to hosts and guests',
  };
  final List<String> _currencies = [
    'INR (₹)',
    'USD (\$)',
    'EUR (€)',
    'GBP (£)',
    'AED (د.إ)'
  ];
  late String _selectedCurrency = _values['currency']!;

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    String? caption,
    required String key,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: caption == null
          ? Text(value)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value),
                const SizedBox(height: 4),
                Text(caption,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
      trailing: TextButton(
        onPressed: () => _showEditor(label, key),
        child: const Text('Edit'),
      ),
    );
  }

  Future<void> _showEditor(String label, String key) async {
    final controller = TextEditingController(text: _values[key]);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $label'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: label),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _values[key] = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal information"),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.lightgreySecond,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _sectionTitle('Basic details'),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildRow('Display name', _values['displayName']!,
                      key: 'displayName'),
                  const Divider(),
                  _buildRow(
                    'Email',
                    _values['email']!,
                    caption: 'Primary login',
                    key: 'email',
                  ),
                  const Divider(),
                  _buildRow(
                    'Phone number',
                    _values['phone']!,
                    caption: 'Verified via SMS',
                    key: 'phone',
                  ),
                ],
              ),
            ),
          ),

          _sectionTitle('Verification & preferences'),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildRow('Location', _values['location']!, key: 'location'),
                  const Divider(),
                  _buildRow('Preferred language', _values['language']!,
                      key: 'language'),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Preferred currency',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(_selectedCurrency),
                    trailing: DropdownButton<String>(
                      value: _selectedCurrency,
                      underline: const SizedBox(),
                      items: _currencies
                          .map((currency) => DropdownMenuItem(
                                value: currency,
                                child: Text(currency),
                              ))
                          .toList(),
                      onChanged: (currency) {
                        if (currency == null) return;
                        setState(() {
                          _selectedCurrency = currency;
                          _values['currency'] = currency;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Preferred currency set to $currency')),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  _buildRow(
                    'Linked accounts',
                    _values['linked']!,
                    caption: 'Connect social logins',
                    key: 'linked',
                  ),
                ],
              ),
            ),
          ),

          _sectionTitle('Communications'),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildRow('Marketing preferences', _values['marketing']!,
                      key: 'marketing'),
                  const Divider(),
                  _buildRow('Discoverability', _values['discoverability']!,
                      key: 'discoverability'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
