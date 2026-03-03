import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/gate_pass_model.dart';

class GatePassScreen extends StatelessWidget {
  const GatePassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Gate Passes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGatePassDialog(context),
        child: const Icon(Icons.add),
      ),
      body: data.gatePasses.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.badge_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No gate passes', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  Text('Tap + to request a gate pass', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.gatePasses.length,
              itemBuilder: (context, index) {
                final gp = data.gatePasses[index];
                final statusColor = {
                  'pending': Colors.orange,
                  'approved': Colors.green,
                  'rejected': Colors.red,
                  'used': Colors.blue,
                  'expired': Colors.grey,
                }[gp.status] ?? Colors.grey;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(gp.destination,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(gp.status.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(gp.reason, style: TextStyle(color: Colors.grey[700])),
                        const SizedBox(height: 8),
                        Text(
                          'Out: ${gp.outDate.day}/${gp.outDate.month}/${gp.outDate.year}'
                          '  •  Return: ${gp.expectedReturnDate.day}/${gp.expectedReturnDate.month}/${gp.expectedReturnDate.year}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        if (gp.wardenRemarks != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Remarks: ${gp.wardenRemarks}',
                                style: TextStyle(color: Colors.blue[700], fontStyle: FontStyle.italic)),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddGatePassDialog(BuildContext context) {
    final reasonCtrl = TextEditingController();
    final destCtrl = TextEditingController();
    DateTime outDate = DateTime.now();
    DateTime returnDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Gate Pass'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: destCtrl,
                decoration: const InputDecoration(labelText: 'Destination'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                decoration: const InputDecoration(labelText: 'Reason'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (destCtrl.text.isEmpty || reasonCtrl.text.isEmpty) return;
              final auth = context.read<AuthProvider>();
              final student = auth.student;
              if (student == null) return;

              final gatePass = GatePassModel(
                id: '',
                studentId: student.uid,
                studentName: student.name,
                roomNumber: student.roomNumber,
                reason: reasonCtrl.text,
                destination: destCtrl.text,
                outDate: outDate,
                expectedReturnDate: returnDate,
                status: 'pending',
                createdAt: DateTime.now(),
              );
              await context.read<DataProvider>().addGatePass(gatePass);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
