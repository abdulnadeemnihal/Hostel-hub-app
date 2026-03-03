import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/complaint_model.dart';
import '../../utils/constants.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Complaints')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddComplaintDialog(context),
        child: const Icon(Icons.add),
      ),
      body: data.complaints.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.report_problem_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No complaints', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  Text('Tap + to register a complaint', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.complaints.length,
              itemBuilder: (context, index) {
                final c = data.complaints[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Chip(label: Text(c.category, style: const TextStyle(fontSize: 11))),
                            const Spacer(),
                            _StatusChip(status: c.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(c.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(c.description, style: TextStyle(color: Colors.grey[700])),
                        if (c.response != null) ...[
                          const Divider(),
                          Text('Response: ${c.response}',
                              style: TextStyle(color: Colors.green[700], fontStyle: FontStyle.italic)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddComplaintDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = AppConstants.complaintCategories.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Complaint'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: AppConstants.complaintCategories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => category = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty) return;
                final auth = context.read<AuthProvider>();
                final student = auth.student;
                if (student == null) return;

                final complaint = ComplaintModel(
                  id: '',
                  studentId: student.uid,
                  studentName: student.name,
                  roomNumber: student.roomNumber,
                  category: category,
                  title: titleCtrl.text,
                  description: descCtrl.text,
                  status: 'pending',
                  createdAt: DateTime.now(),
                );
                await context.read<DataProvider>().addComplaint(complaint);
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

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'pending': Colors.orange,
      'in_progress': Colors.blue,
      'resolved': Colors.green,
      'rejected': Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (colors[status] ?? Colors.grey).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.bold, color: colors[status] ?? Colors.grey),
      ),
    );
  }
}
