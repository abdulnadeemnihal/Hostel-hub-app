import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final filtered = _filterStatus == 'all'
        ? data.leaves
        : data.leaves.where((l) => l.status == _filterStatus).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Leave Applications',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'pending', label: Text('Pending')),
                  ButtonSegment(value: 'approved', label: Text('Approved')),
                  ButtonSegment(value: 'rejected', label: Text('Rejected')),
                ],
                selected: {_filterStatus},
                onSelectionChanged: (v) => setState(() => _filterStatus = v.first),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No leave applications', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final l = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(l.studentName,
                                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        Text('Room ${l.roomNumber} • ${l.leaveType}',
                                            style: TextStyle(color: Colors.grey[600])),
                                      ],
                                    ),
                                  ),
                                  _StatusChip(status: l.status),
                                ],
                              ),
                              const Divider(),
                              _InfoRow('Reason', l.reason),
                              _InfoRow('Destination', l.destination),
                              _InfoRow('Dates',
                                  '${DateFormat('dd MMM').format(l.fromDate)} - ${DateFormat('dd MMM yyyy').format(l.toDate)} (${l.leaveDays} days)'),
                              if (l.parentPhone != null)
                                _InfoRow('Parent Phone', l.parentPhone!),
                              if (l.status == 'pending') ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _handleAction(l.id, 'approved'),
                                      icon: const Icon(Icons.check, size: 18),
                                      label: const Text('Approve'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () => _handleAction(l.id, 'rejected'),
                                      icon: const Icon(Icons.close, size: 18, color: Colors.red),
                                      label: const Text('Reject', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _handleAction(String id, String status) {
    final remarksCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${status == 'approved' ? 'Approve' : 'Reject'} Leave'),
        content: TextField(
          controller: remarksCtrl,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Remarks (optional)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<DataProvider>().updateLeave(
                  id, status, remarksCtrl.text.isEmpty ? null : remarksCtrl.text);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: status == 'approved' ? Colors.green : Colors.red),
            child: Text(status == 'approved' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = {'pending': Colors.orange, 'approved': Colors.green, 'rejected': Colors.red};
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (colors[status] ?? Colors.grey).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status.toUpperCase(),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold,
              color: colors[status] ?? Colors.grey)),
    );
  }
}
