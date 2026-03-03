import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = context.watch<AuthProvider>().student;

    return Scaffold(
      appBar: AppBar(title: const Text('Room Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // Room Info Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.bed, size: 48, color: Colors.teal),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Room ${student?.roomNumber ?? 'Unassigned'}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          student?.hostelBlock ?? 'Not Assigned',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Room Details
                _DetailCard(
                  title: 'Room Information',
                  items: [
                    _DetailItem('Room Number', student?.roomNumber ?? 'Unassigned', Icons.door_front_door),
                    _DetailItem('Hostel Block', student?.hostelBlock ?? 'Unassigned', Icons.apartment),
                    _DetailItem('Room Type', 'Double Sharing', Icons.people),
                    _DetailItem('Floor', '2nd Floor', Icons.layers),
                  ],
                ),
                const SizedBox(height: 16),

                // Amenities
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Room Amenities',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _AmenityChip('Wi-Fi', Icons.wifi),
                            _AmenityChip('Fan', Icons.air),
                            _AmenityChip('Desk', Icons.desk),
                            _AmenityChip('Cupboard', Icons.storage),
                            _AmenityChip('Bed', Icons.bed),
                            _AmenityChip('Chair', Icons.chair),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<_DetailItem> items;

  const _DetailCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...items.map((item) => ListTile(
                  leading: Icon(item.icon, color: Colors.teal),
                  title: Text(item.label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  subtitle: Text(item.value,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                )),
          ],
        ),
      ),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  final IconData icon;
  _DetailItem(this.label, this.value, this.icon);
}

class _AmenityChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _AmenityChip(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.teal),
      label: Text(label),
      backgroundColor: Colors.teal.withValues(alpha: 0.1),
    );
  }
}
