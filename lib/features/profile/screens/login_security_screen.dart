import 'package:flutter/material.dart';
import 'package:tripsuite_app_boilerplate/core/theme/app_theme.dart';
import 'package:tripsuite_app_boilerplate/features/auth/services/auth_service.dart';

class LoginSecurityScreen extends StatefulWidget {
  const LoginSecurityScreen({super.key});

  @override
  State<LoginSecurityScreen> createState() => _LoginSecurityScreenState();
}

class _LoginSecurityScreenState extends State<LoginSecurityScreen> {
  bool _twoFactor = true;
  final List<Map<String, String>> _recentLogins = [
    {'device': 'This device', 'location': 'Pune, India', 'time': 'Active'},
    {'device': 'iPhone 14', 'location': 'Pune, India', 'time': '3 hours ago'},
    {'device': 'Web · Chrome', 'location': 'Mumbai, India', 'time': 'Yesterday'},
    {'device': 'Pixel 6', 'location': 'Delhi, India', 'time': 'Last week'},
  ];

  String _email = 'pranali@gmail.com';
  String _maskedPassword = '••••••••';
  final AuthService _authService = AuthService();


  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildRow(String label, String value, {String? trailing, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value),
      trailing: trailing != null
          ? TextButton(onPressed: onTap, child: Text(trailing))
          : null,
    );
  }

  Future<void> _showInputDialog({
    required String title,
    required String hintText,
    required Future<void> Function(String value) onSave,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hintText),
          obscureText: obscureText,
          keyboardType: keyboardType,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await onSave(result);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _manageSecurityKeys() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Security keys',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Add a hardware security key or manage existing ones that can unlock your account.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const ListTile(
                title: Text('YubiKey 5 NFC'),
                subtitle: Text('Added 2 days ago'),
              ),
              const Divider(),
              const ListTile(
                title: Text('Google Titan'),
                subtitle: Text('Added a month ago'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text('Security key added'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Add new key'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmSignOut(int index) async {
    final device = _recentLogins[index]['device'];
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out'),
        content: Text('Do you really want to sign out $device?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes')),
        ],
      ),
    );
    if (result == true) {
      if (_recentLogins[index]['device'] == 'This device') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot sign out the current device')),
        );
        return;
      }
      _removeDevice(index);
    }
  }

  void _removeDevice(int index) {
    setState(() {
      _recentLogins.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device signed out')),
    );
  }

  Future<void> _confirmSignOutAll() async {
    if (_recentLogins.isEmpty) return;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out of all devices'),
        content: const Text('Are you sure you want to sign out of all other devices?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes')),
        ],
      ),
    );
    if (result == true) {
      _signOutAllDevices();
    }
  }

  void _signOutAllDevices() {
    setState(() => _recentLogins.removeWhere((info) => info['device'] != 'This device'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signed out of all other devices')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login & security"),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.lightgreySecond,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _sectionHeader('Primary login'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildRow('Email', _email, trailing: 'Change', onTap: () {
                    _showInputDialog(
                      title: 'Update email',
                      hintText: 'Email address',
                      initialValue: _email,
                      keyboardType: TextInputType.emailAddress,
                      onSave: (value) async {
                        // Firebase currently requires reauthentication for sensitive changes.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Email update is currently unsupported in this demo.'),
                          ),
                        );
                      },
                    );
                  }),
                  const Divider(),
                  _buildRow('Password', _maskedPassword, trailing: 'Update', onTap: () {
                    _showInputDialog(
                      title: 'Update password',
                      hintText: 'Enter new password',
                      obscureText: true,
                      onSave: (value) async {
                        await _authService.updatePassword(value);
                        setState(() {
                          _maskedPassword = value.isNotEmpty ? '••••••••' : '';
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password updated')),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          _sectionHeader('Security'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Two-factor authentication'),
                    subtitle: const Text('Add an extra code sent via SMS or authenticator'),
                    value: _twoFactor,
                    onChanged: (value) => setState(() => _twoFactor = value),
                  ),
                  const Divider(),
                  _buildRow('Recovery options', 'Phone, backup codes', trailing: 'Manage', onTap: () {}),
                  const Divider(),
                  _buildRow('Security keys', 'Manage hardware keys', trailing: 'Add', onTap: _manageSecurityKeys),
                ],
              ),
            ),
          ),

          _sectionHeader('Devices & sessions'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < _recentLogins.length; i++) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _recentLogins[i]['device']!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('${_recentLogins[i]['location']} · ${_recentLogins[i]['time']}'),
                      trailing: TextButton(
                        onPressed: () => _confirmSignOut(i),
                        child: const Text('Sign out'),
                      ),
                    ),
                    if (i != _recentLogins.length - 1) const Divider(),
                  ],
                  const SizedBox(height: 12),
                  Center(
                    child: OutlinedButton(
                      onPressed: _recentLogins.isEmpty ? null : _confirmSignOutAll,
                      child: const Text('Sign out of all devices'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
