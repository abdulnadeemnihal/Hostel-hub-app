import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final filtered = data.students.where((s) =>
        s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.rollNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.roomNumber.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Students (${data.students.length})',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              SizedBox(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search students...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No students found', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final s = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text(s.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${s.rollNumber} • ${s.department} • ${s.year}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Room: ${s.roomNumber}',
                                  style: const TextStyle(fontWeight: FontWeight.w500)),
                              Text(s.hostelBlock,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                          onTap: () => _showStudentDetails(context, s),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showStudentDetails(BuildContext context, dynamic student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(student.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow('Email', student.email),
              _infoRow('Phone', student.phone),
              _infoRow('Roll Number', student.rollNumber),
              _infoRow('Department', student.department),
              _infoRow('Year', student.year),
              _infoRow('Room', student.roomNumber),
              _infoRow('Block', student.hostelBlock),
              if (student.parentPhone != null)
                _infoRow('Parent Phone', student.parentPhone!),
              if (student.address != null)
                _infoRow('Address', student.address!),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showAssignRoomDialog(context, student);
            },
            child: const Text('Assign Room'),
          ),
        ],
      ),
    );
  }

  void _showAssignRoomDialog(BuildContext context, dynamic student) {
    final roomCtrl = TextEditingController(text: student.roomNumber);
    final blockCtrl = TextEditingController(text: student.hostelBlock);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Assign Room - ${student.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: roomCtrl,
              decoration: const InputDecoration(labelText: 'Room Number'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: blockCtrl,
              decoration: const InputDecoration(labelText: 'Hostel Block'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await context.read<DataProvider>().assignRoom(
                student.uid,
                roomCtrl.text,
                blockCtrl.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label,
              style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
