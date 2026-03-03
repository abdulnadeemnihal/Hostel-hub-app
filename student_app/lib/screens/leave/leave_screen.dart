import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/leave_model.dart';
import '../../utils/constants.dart';

class LeaveScreen extends StatelessWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Applications')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLeaveDialog(context),
        child: const Icon(Icons.add),
      ),
      body: data.leaves.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No leave applications', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  Text('Tap + to apply for leave', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.leaves.length,
              itemBuilder: (context, index) {
                final l = data.leaves[index];
                final statusColor = {
                  'pending': Colors.orange,
                  'approved': Colors.green,
                  'rejected': Colors.red,
                }[l.status] ?? Colors.grey;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Chip(label: Text(l.leaveType, style: const TextStyle(fontSize: 11))),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(l.status.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(l.reason,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(
                          '${l.fromDate.day}/${l.fromDate.month}/${l.fromDate.year}'
                          ' → ${l.toDate.day}/${l.toDate.month}/${l.toDate.year}'
                          '  (${l.leaveDays} days)',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                        Text('Destination: ${l.destination}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        if (l.wardenRemarks != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Remarks: ${l.wardenRemarks}',
                                style: TextStyle(
                                    color: Colors.blue[700], fontStyle: FontStyle.italic)),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddLeaveDialog(BuildContext context) {
    final reasonCtrl = TextEditingController();
    final destCtrl = TextEditingController();
    String leaveType = AppConstants.leaveTypes.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Apply for Leave'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: leaveType,
                  decoration: const InputDecoration(labelText: 'Leave Type'),
                  items: AppConstants.leaveTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => leaveType = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: destCtrl,
                  decoration: const InputDecoration(labelText: 'Destination'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonCtrl,
                  decoration: const InputDecoration(labelText: 'Reason'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (reasonCtrl.text.isEmpty || destCtrl.text.isEmpty) return;
                final auth = context.read<AuthProvider>();
                final student = auth.student;
                if (student == null) return;

                final leave = LeaveApplication(
                  id: '',
                  studentId: student.uid,
                  studentName: student.name,
                  roomNumber: student.roomNumber,
                  reason: reasonCtrl.text,
                  leaveType: leaveType,
                  fromDate: DateTime.now(),
                  toDate: DateTime.now().add(const Duration(days: 2)),
                  status: 'pending',
                  destination: destCtrl.text,
                  createdAt: DateTime.now(),
                );
                await context.read<DataProvider>().addLeave(leave);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
