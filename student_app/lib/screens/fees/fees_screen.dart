import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Fee Management')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Total Fees',
                    value: '₹${data.fees.fold<double>(0, (sum, f) => sum + f.amount).toStringAsFixed(0)}',
                    color: Colors.blue,
                    icon: Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Paid',
                    value: '₹${data.fees.fold<double>(0, (sum, f) => sum + f.paidAmount).toStringAsFixed(0)}',
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Pending',
                    value: '₹${data.totalPendingFees.toStringAsFixed(0)}',
                    color: Colors.red,
                    icon: Icons.pending,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text('Fee Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            if (data.fees.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No fee records', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              ...data.fees.map((fee) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_getFeeTypeLabel(fee.feeType),
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w600)),
                              _StatusChip(status: fee.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${fee.semester} • ${fee.academicYear}',
                                  style: TextStyle(color: Colors.grey[600])),
                              Text('₹${fee.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          if (fee.pendingAmount > 0) ...[
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: fee.paidAmount / fee.amount,
                              backgroundColor: Colors.grey[200],
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Paid: ₹${fee.paidAmount.toStringAsFixed(0)} / ₹${fee.amount.toStringAsFixed(0)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                          if (fee.paidDate != null)
                            Text(
                              'Paid on: ${fee.paidDate!.day}/${fee.paidDate!.month}/${fee.paidDate!.year}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          Text(
                            'Due: ${fee.dueDate.day}/${fee.dueDate.month}/${fee.dueDate.year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: fee.dueDate.isBefore(DateTime.now()) && !fee.isPaid
                                  ? Colors.red
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  String _getFeeTypeLabel(String type) {
    switch (type) {
      case 'hostel':
        return 'Hostel Fee';
      case 'mess':
        return 'Mess Fee';
      case 'maintenance':
        return 'Maintenance Fee';
      case 'security_deposit':
        return 'Security Deposit';
      default:
        return type;
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
      'paid': Colors.green,
      'pending': Colors.orange,
      'overdue': Colors.red,
      'partial': Colors.blue,
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
            fontSize: 11, fontWeight: FontWeight.bold, color: colors[status] ?? Colors.grey),
      ),
    );
  }
}
