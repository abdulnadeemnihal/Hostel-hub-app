import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Stats Grid
          LayoutBuilder(builder: (context, constraints) {
            final crossCount = constraints.maxWidth > 900
                ? 5
                : constraints.maxWidth > 600
                    ? 3
                    : 2;
            return GridView.count(
              crossAxisCount: crossCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _StatCard(
                  icon: Icons.people, label: 'Total Students',
                  value: '${data.totalStudents}', color: Colors.blue,
                ),
                _StatCard(
                  icon: Icons.report_problem, label: 'Pending Complaints',
                  value: '${data.pendingComplaints}', color: Colors.orange,
                ),
                _StatCard(
                  icon: Icons.event_note, label: 'Pending Leaves',
                  value: '${data.pendingLeaves}', color: Colors.purple,
                ),
                _StatCard(
                  icon: Icons.bed, label: 'Rooms Occupied',
                  value: '${data.occupiedRooms}/${data.totalRooms}', color: Colors.teal,
                ),
                _StatCard(
                  icon: Icons.qr_code_2, label: 'Pending Passes',
                  value: '${data.pendingGatePasses}', color: Colors.brown,
                ),
              ],
            );
          }),
          const SizedBox(height: 24),

          // Fee Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fee Collection Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _FeeStatCard(
                        label: 'Collected', value: data.totalCollectedFees,
                        color: Colors.green,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _FeeStatCard(
                        label: 'Pending', value: data.totalPendingFees,
                        color: Colors.red,
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recent Activity
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent Complaints
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Recent Complaints',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Divider(),
                        if (data.complaints.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No complaints', style: TextStyle(color: Colors.grey)),
                          )
                        else
                          ...data.complaints.take(5).map((c) => ListTile(
                                dense: true,
                                leading: _statusDot(c.status),
                                title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text('${c.studentName} • ${c.category}',
                                    style: const TextStyle(fontSize: 12)),
                                trailing: Text(c.status,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: _statusColor(c.status),
                                        fontWeight: FontWeight.w600)),
                              )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Recent Leave Requests
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Recent Leave Requests',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Divider(),
                        if (data.leaves.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('No leave requests', style: TextStyle(color: Colors.grey)),
                          )
                        else
                          ...data.leaves.take(5).map((l) => ListTile(
                                dense: true,
                                leading: _statusDot(l.status),
                                title: Text(l.studentName,
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text('${l.leaveType} • ${l.leaveDays} days',
                                    style: const TextStyle(fontSize: 12)),
                                trailing: Text(l.status,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: _statusColor(l.status),
                                        fontWeight: FontWeight.w600)),
                              )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusDot(String status) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _statusColor(status),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _FeeStatCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _FeeStatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('₹${value.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
