import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final filtered = _filterStatus == 'all'
        ? data.complaints
        : data.complaints.where((c) => c.status == _filterStatus).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Complaints',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'pending', label: Text('Pending')),
                  ButtonSegment(value: 'in_progress', label: Text('In Progress')),
                  ButtonSegment(value: 'resolved', label: Text('Resolved')),
                ],
                selected: {_filterStatus},
                onSelectionChanged: (v) => setState(() => _filterStatus = v.first),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No complaints', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: _statusDot(c.status),
                          title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${c.studentName} • ${c.category} • Room ${c.roomNumber}'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.description),
                                  const SizedBox(height: 12),
                                  Text('Submitted: ${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      if (c.status == 'pending') ...[
                                        ElevatedButton.icon(
                                          onPressed: () => _updateStatus(c.id, 'in_progress'),
                                          icon: const Icon(Icons.play_arrow, size: 18),
                                          label: const Text('Accept'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      if (c.status != 'resolved') ...[
                                        ElevatedButton.icon(
                                          onPressed: () => _showResolveDialog(c.id),
                                          icon: const Icon(Icons.check, size: 18),
                                          label: const Text('Resolve'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      if (c.status == 'pending')
                                        OutlinedButton.icon(
                                          onPressed: () => _updateStatus(c.id, 'rejected'),
                                          icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                          label: const Text('Reject', style: TextStyle(color: Colors.red)),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statusDot(String status) {
    final colors = {
      'pending': Colors.orange,
      'in_progress': Colors.blue,
      'resolved': Colors.green,
      'rejected': Colors.red,
    };
    return Container(
      width: 12, height: 12,
      decoration: BoxDecoration(shape: BoxShape.circle, color: colors[status] ?? Colors.grey),
    );
  }

  void _updateStatus(String id, String status) {
    context.read<DataProvider>().updateComplaint(id, status, null);
  }

  void _showResolveDialog(String id) {
    final responseCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resolve Complaint'),
        content: TextField(
          controller: responseCtrl,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Response/Resolution'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<DataProvider>().updateComplaint(id, 'resolved', responseCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }
}
