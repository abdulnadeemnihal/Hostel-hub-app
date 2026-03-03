import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _parentPhoneCtrl;
  late TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    final student = context.read<AuthProvider>().student;
    _nameCtrl = TextEditingController(text: student?.name ?? '');
    _phoneCtrl = TextEditingController(text: student?.phone ?? '');
    _parentPhoneCtrl = TextEditingController(text: student?.parentPhone ?? '');
    _addressCtrl = TextEditingController(text: student?.address ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _parentPhoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    await context.read<AuthProvider>().updateProfile({
      'name': _nameCtrl.text,
      'phone': _phoneCtrl.text,
      'parentPhone': _parentPhoneCtrl.text,
      'address': _addressCtrl.text,
    });
    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final student = auth.student;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    (student?.name ?? 'S')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 36, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(student?.name ?? '', style: Theme.of(context).textTheme.headlineSmall),
                Text(student?.email ?? '', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 24),
                if (_isEditing) ...[
                  _buildEditField('Name', _nameCtrl, Icons.person),
                  _buildEditField('Phone', _phoneCtrl, Icons.phone),
                  _buildEditField('Parent Phone', _parentPhoneCtrl, Icons.phone_in_talk),
                  _buildEditField('Address', _addressCtrl, Icons.home, maxLines: 3),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _saveProfile,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                  ),
                ] else ...[
                  _buildInfoTile('Roll Number', student?.rollNumber ?? '', Icons.badge),
                  _buildInfoTile('Department', student?.department ?? '', Icons.business),
                  _buildInfoTile('Year', student?.year ?? '', Icons.calendar_today),
                  _buildInfoTile('Room', student?.roomNumber ?? 'Unassigned', Icons.bed),
                  _buildInfoTile('Block', student?.hostelBlock ?? 'Unassigned', Icons.apartment),
                  _buildInfoTile('Phone', student?.phone ?? '', Icons.phone),
                  _buildInfoTile('Parent Phone', student?.parentPhone ?? 'Not set', Icons.phone_in_talk),
                  _buildInfoTile('Address', student?.address ?? 'Not set', Icons.home),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildEditField(String label, TextEditingController ctrl, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}
