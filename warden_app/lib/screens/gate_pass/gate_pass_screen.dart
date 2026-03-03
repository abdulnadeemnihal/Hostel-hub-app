import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../models/gate_pass_model.dart';

class GatePassScreen extends StatefulWidget {
  const GatePassScreen({super.key});

  @override
  State<GatePassScreen> createState() => _GatePassScreenState();
}

class _GatePassScreenState extends State<GatePassScreen> {
  String _filter = 'pending';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final passes = _filter == 'all'
        ? data.gatePasses
        : data.gatePasses.where((g) => g.status == _filter).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Gate Pass Requests',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${passes.length} requests',
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'pending', label: Text('Pending')),
              ButtonSegment(value: 'approved', label: Text('Approved')),
              ButtonSegment(value: 'rejected', label: Text('Rejected')),
              ButtonSegment(value: 'all', label: Text('All')),
            ],
            selected: {_filter},
            onSelectionChanged: (s) => setState(() => _filter = s.first),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: passes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.door_front_door,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text('No gate pass requests',
                            style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: passes.length,
                    itemBuilder: (context, index) {
                      final pass = passes[index];
                      return _GatePassCard(
                        pass: pass,
                        onApprove: () => _approvePass(data, pass),
                        onReject: () => _showRejectDialog(context, data, pass),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _approvePass(DataProvider data, GatePassModel pass) async {
    await data.updateGatePass(pass.id, {
      'status': 'approved',
      'approvedBy': 'Warden',
      'approvedAt': DateTime.now().toIso8601String(),
    });
  }

  void _showRejectDialog(
      BuildContext context, DataProvider data, GatePassModel pass) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Gate Pass'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Student: ${pass.studentName}'),
            Text('Reason: ${pass.reason}'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Rejection Reason', alignLabelWithHint: true),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await data.updateGatePass(pass.id, {
                'status': 'rejected',
                'rejectionReason': reasonCtrl.text.trim(),
                'approvedBy': 'Warden',
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _GatePassCard extends StatelessWidget {
  final GatePassModel pass;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  const _GatePassCard(
      {required this.pass, required this.onApprove, required this.onReject});

  Color get _statusColor {
    switch (pass.status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _statusColor.withValues(alpha: 0.15),
                  child: Icon(Icons.person, color: _statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pass.studentName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Room: ${pass.roomNumber}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pass.status.toUpperCase(),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _statusColor),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _InfoChip(Icons.logout, 'Out',
                    DateFormat('dd MMM, hh:mm a').format(pass.outDate)),
                const SizedBox(width: 16),
                _InfoChip(Icons.login, 'Expected Return',
                    DateFormat('dd MMM, hh:mm a').format(pass.expectedReturnDate)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.place, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(pass.destination,
                        style: TextStyle(color: Colors.grey.shade700))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.note, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(pass.reason,
                        style: TextStyle(color: Colors.grey.shade700))),
              ],
            ),
            if (pass.status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text('$label: ', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
