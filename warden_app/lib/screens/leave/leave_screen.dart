import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../models/leave_model.dart';

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
              const Text(
                'Leave Applications',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'pending', label: Text('Pending')),
                  ButtonSegment(value: 'approved', label: Text('Approved')),
                  ButtonSegment(value: 'rejected', label: Text('Rejected')),
                ],
                selected: {_filterStatus},
                onSelectionChanged: (v) =>
                    setState(() => _filterStatus = v.first),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No leave applications',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final l = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showLeaveDetail(context, l),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l.studentName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Room ${l.roomNumber} • ${l.leaveType} • ${l.leaveReason}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _StatusChip(status: l.status),
                                  ],
                                ),
                                const Divider(),
                                _InfoRow(
                                  'Dates',
                                  '${DateFormat('dd MMM').format(l.fromDate)} - ${DateFormat('dd MMM yyyy').format(l.toDate)} (${l.leaveDays} days)',
                                ),
                                if (l.fromTime != null && l.toTime != null)
                                  _InfoRow(
                                    'Time',
                                    '${l.fromTime} - ${l.toTime}',
                                  ),
                                _InfoRow('Destination', l.destination),
                                _InfoRow('Transport', l.modeOfTransport),
                                if (l.parentPhone != null)
                                  _InfoRow('Parent Phone', l.parentPhone!),
                                if (l.status == 'pending') ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _handleAction(l.id, 'approved'),
                                        icon: const Icon(Icons.check, size: 18),
                                        label: const Text('Approve'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            _handleAction(l.id, 'rejected'),
                                        icon: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                        label: const Text(
                                          'Reject',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
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

  void _showLeaveDetail(BuildContext context, LeaveApplication l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Expanded(
              child: Text(
                'Leave Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _StatusChip(status: l.status),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow('Student', l.studentName),
              _DetailRow('Room', l.roomNumber),
              const Divider(),
              _DetailRow('Leave Type', l.leaveType),
              _DetailRow('Leave Reason', l.leaveReason),
              _DetailRow(
                'From Date',
                DateFormat('dd MMM yyyy').format(l.fromDate),
              ),
              _DetailRow('To Date', DateFormat('dd MMM yyyy').format(l.toDate)),
              if (l.fromTime != null) _DetailRow('From Time', l.fromTime!),
              if (l.toTime != null) _DetailRow('To Time', l.toTime!),
              _DetailRow('Total Days', '${l.leaveDays} days'),
              const Divider(),
              _DetailRow('Destination', l.destination),
              _DetailRow('Transport', l.modeOfTransport),
              _DetailRow('Parent Phone', l.parentPhone ?? 'N/A'),
              const Divider(),
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(l.description, style: TextStyle(color: Colors.grey[700])),
              if (l.photoUrls.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Photos Attached',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l.photoUrls.length} photo(s)',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ],
              if (l.wardenRemarks != null) ...[
                const Divider(),
                const Text(
                  'Your Remarks',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  l.wardenRemarks!,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const Divider(),
              _DetailRow('T&C Accepted', l.termsAccepted ? 'Yes' : 'No'),
              _DetailRow(
                'Applied On',
                DateFormat('dd MMM yyyy, hh:mm a').format(l.createdAt),
              ),
              // ── Gate Log Info ──
              if (l.gateStatus != null) ...[
                const Divider(),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: l.gateStatus == 'out'
                        ? Colors.orange.shade50
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: l.gateStatus == 'out'
                          ? Colors.orange.shade300
                          : Colors.green.shade300,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            l.gateStatus == 'out'
                                ? Icons.logout
                                : Icons.login,
                            size: 18,
                            color: l.gateStatus == 'out'
                                ? Colors.orange.shade700
                                : Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Gate Status: ${l.gateStatus == 'out' ? 'OUT OF HOSTEL' : 'RETURNED'}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: l.gateStatus == 'out'
                                  ? Colors.orange.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (l.gateExitTime != null)
                        _DetailRow(
                          'Exit Time',
                          DateFormat('dd MMM yyyy, hh:mm a')
                              .format(l.gateExitTime!),
                        ),
                      if (l.gateReturnTime != null)
                        _DetailRow(
                          'Return Time',
                          DateFormat('dd MMM yyyy, hh:mm a')
                              .format(l.gateReturnTime!),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          if (l.status == 'pending') ...[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _handleAction(l.id, 'approved');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Approve'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _handleAction(l.id, 'rejected');
              },
              child: const Text('Reject', style: TextStyle(color: Colors.red)),
            ),
          ],
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DataProvider>().updateLeave(
                id,
                status,
                remarksCtrl.text.isEmpty ? null : remarksCtrl.text,
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'approved' ? Colors.green : Colors.red,
            ),
            child: Text(status == 'approved' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
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
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
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
    final colors = {
      'pending': Colors.orange,
      'approved': Colors.green,
      'rejected': Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (colors[status] ?? Colors.grey).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: colors[status] ?? Colors.grey,
        ),
      ),
    );
  }
}
