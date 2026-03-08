import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/gate_data_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<GateDataProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today — ${DateFormat('EEEE, MMM d, yyyy').format(DateTime.now())}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          // Stats cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.logout,
                  label: 'Exits Today',
                  value: '${data.todayExits}',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.login,
                  label: 'Returns Today',
                  value: '${data.todayReturns}',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.person_off,
                  label: 'Currently Out',
                  value: '${data.currentlyOut < 0 ? 0 : data.currentlyOut}',
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (data.todayLogs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text('No gate activity today',
                        style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              ),
            )
          else
            ...data.todayLogs.take(20).map((log) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: log.action == 'exit'
                          ? Colors.orange.shade100
                          : Colors.green.shade100,
                      child: Icon(
                        log.action == 'exit' ? Icons.logout : Icons.login,
                        color: log.action == 'exit'
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                    title: Text(log.studentName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        'Room ${log.roomNumber} • ${log.passType == 'leave' ? 'Leave' : 'Gate Pass'}'),
                    trailing: Text(
                      DateFormat('hh:mm a').format(log.scannedAt),
                      style: TextStyle(
                        color: log.action == 'exit'
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
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
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
