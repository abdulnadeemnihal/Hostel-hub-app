import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/gate_data_provider.dart';

class GateLogsScreen extends StatelessWidget {
  const GateLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<GateDataProvider>();
    final logs = data.allLogs;

    if (logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text('No gate logs yet',
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    // Group logs by date
    final grouped = <String, List<dynamic>>{};
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    for (final log in logs) {
      final dateKey = dateFormat.format(log.scannedAt);
      grouped.putIfAbsent(dateKey, () => []).add(log);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final dateKey = grouped.keys.elementAt(index);
        final dayLogs = grouped[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(dateKey,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
            ),
            ...dayLogs.map((log) => Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: log.action == 'exit'
                          ? Colors.orange.shade100
                          : Colors.green.shade100,
                      child: Icon(
                        log.action == 'exit' ? Icons.logout : Icons.login,
                        size: 18,
                        color: log.action == 'exit'
                            ? Colors.orange.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                    title: Text(log.studentName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        'Room ${log.roomNumber} • ${log.passType == 'leave' ? 'Leave' : 'Gate Pass'} • ${log.action.toUpperCase()}'),
                    trailing: Text(
                      timeFormat.format(log.scannedAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                )),
            if (index < grouped.length - 1) const Divider(),
          ],
        );
      },
    );
  }
}
