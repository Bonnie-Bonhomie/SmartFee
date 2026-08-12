import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _studentCtrl;
  late TextEditingController _classCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _studentCtrl = TextEditingController();
    _classCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
  }

  void _hydrate(UserProvider provider) {
    if (_initialized) return;
    final p = provider.profile;
    if (p != null) {
      _nameCtrl.text = p.fullName;
      _studentCtrl.text = p.studentName;
      _classCtrl.text = p.className;
      _emailCtrl.text = p.email ?? '';
      _phoneCtrl.text = p.phone ?? '';
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _studentCtrl.dispose();
    _classCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(UserProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    await provider.saveProfile(
      fullName: _nameCtrl.text.trim(),
      studentName: _studentCtrl.text.trim(),
      className: _classCtrl.text.trim(),
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved locally on this device.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        _hydrate(provider);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This profile is stored only on your device. '
                  'It is optional and is not used to process payments.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Your Full Name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _studentCtrl,
                  decoration: const InputDecoration(labelText: 'Student Name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _classCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Level/ Grade'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Email (optional)'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Phone (optional)'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _save(provider),
                  icon: const Icon(Icons.save),
                  label: const Text('Save Profile'),
                ),
                if (provider.isRegistered) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await provider.clearProfile();
                      _nameCtrl.clear();
                      _studentCtrl.clear();
                      _classCtrl.clear();
                      _emailCtrl.clear();
                      _phoneCtrl.clear();
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove Local Profile'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
