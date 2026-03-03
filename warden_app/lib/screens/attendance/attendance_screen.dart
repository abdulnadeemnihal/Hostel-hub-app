import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../models/attendance_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    var records = data.attendance.where((a) {
      final aDate = DateFormat('yyyy-MM-dd').format(a.date);
      return aDate == dateStr;
    }).toList();

    if (_filterStatus != 'all') {
      records = records.where((a) => a.status == _filterStatus).toList();
    }

    final present = data.attendance
        .where((a) =>
            DateFormat('yyyy-MM-dd').format(a.date) == dateStr &&
            a.status == 'present')
        .length;
    final absent = data.attendance
        .where((a) =>
            DateFormat('yyyy-MM-dd').format(a.date) == dateStr &&
            a.status == 'absent')
        .length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Attendance',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              _MiniStat('Present', '$present', Colors.green),
              const SizedBox(width: 8),
              _MiniStat('Absent', '$absent', Colors.red),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showMarkAttendanceDialog(context, data),
                icon: const Icon(Icons.add_task),
                label: const Text('Mark Attendance'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'present', label: Text('Present')),
                  ButtonSegment(value: 'absent', label: Text('Absent')),
                  ButtonSegment(value: 'late', label: Text('Late')),
                ],
                selected: {_filterStatus},
                onSelectionChanged: (s) => setState(() => _filterStatus = s.first),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: records.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.how_to_reg, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text('No attendance records for this date',
                            style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final rec = records[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _statusColor(rec.status).withValues(alpha: 0.15),
                            child: Icon(_statusIcon(rec.status),
                                color: _statusColor(rec.status)),
                          ),
                          title: Text(rec.studentName,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Marked at ${DateFormat('hh:mm a').format(rec.date)}'),
                          trailing: Chip(
                            label: Text(
                              rec.status.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: _statusColor(rec.status),
                                  fontWeight: FontWeight.bold),
                            ),
                            backgroundColor:
                                _statusColor(rec.status).withValues(alpha: 0.1),
                            side: BorderSide.none,
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

  Color _statusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'late':
        return Icons.watch_later;
      default:
        return Icons.help;
    }
  }

  void _showMarkAttendanceDialog(BuildContext context, DataProvider data) {
    final Map<String, String> studentStatuses = {};
    for (final s in data.students) {
      studentStatuses[s.uid] = 'present';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
              'Mark Attendance - ${DateFormat('dd MMM').format(_selectedDate)}'),
          content: SizedBox(
            width: 500,
            height: 400,
            child: data.students.isEmpty
                ? const Center(child: Text('No students found'))
                : ListView.builder(
                    itemCount: data.students.length,
                    itemBuilder: (context, index) {
                      final student = data.students[index];
                      final status = studentStatuses[student.uid] ?? 'present';
                      return ListTile(
                        title: Text(student.name),
                        subtitle: Text(student.rollNumber),
                        trailing: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                                value: 'present',
                                icon: Icon(Icons.check, size: 16)),
                            ButtonSegment(
                                value: 'absent',
                                icon: Icon(Icons.close, size: 16)),
                            ButtonSegment(
                                value: 'late',
                                icon: Icon(Icons.watch_later, size: 16)),
                          ],
                          selected: {status},
                          onSelectionChanged: (s) {
                            setDialogState(
                                () => studentStatuses[student.uid] = s.first);
                          },
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                for (final entry in studentStatuses.entries) {
                  final student = data.students
                      .firstWhere((s) => s.uid == entry.key);
                  final rec = AttendanceModel(
                    id: '',
                    studentId: entry.key,
                    studentName: student.name,
                    roomNumber: student.roomNumber,
                    date: _selectedDate,
                    status: entry.value,
                    markedBy: 'warden',
                    createdAt: DateTime.now(),
                  );
                  await data.markAttendance(rec);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save Attendance'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
