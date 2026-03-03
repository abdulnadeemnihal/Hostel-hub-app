import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import 'package:intl/intl.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final filtered = _filterStatus == 'all'
        ? data.fees
        : data.fees.where((f) => f.status == _filterStatus).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text('Fee Management',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              _summaryChip('Collected', data.totalCollectedFees, Colors.green),
              const SizedBox(width: 8),
              _summaryChip('Pending', data.totalPendingFees, Colors.red),
            ],
          ),
          const SizedBox(height: 16),

          // Filters
          Wrap(
            spacing: 8,
            children: ['all', 'paid', 'pending', 'overdue', 'partial']
                .map((s) => ChoiceChip(
                      label: Text(s[0].toUpperCase() + s.substring(1)),
                      selected: _filterStatus == s,
                      onSelected: (_) => setState(() => _filterStatus = s),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Table
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No fee records found.'))
                : SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Student')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: Text('Paid')),
                        DataColumn(label: Text('Due Date')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: filtered.map((f) {
                        return DataRow(cells: [
                          DataCell(Text(f.studentName)),
                          DataCell(Text(f.feeType)),
                          DataCell(Text('₹${f.amount.toStringAsFixed(0)}')),
                          DataCell(Text('₹${f.paidAmount.toStringAsFixed(0)}')),
                          DataCell(Text(DateFormat('dd MMM yyyy').format(f.dueDate))),
                          DataCell(_statusBadge(f.status)),
                        ]);
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, double value, Color color) {
    return Chip(
      avatar: CircleAvatar(backgroundColor: color, radius: 6),
      label: Text('$label: ₹${value.toStringAsFixed(0)}'),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'paid':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'overdue':
        color = Colors.red;
        break;
      case 'partial':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status,
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
