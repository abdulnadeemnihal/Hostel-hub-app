import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/student_model.dart';
import '../../models/leave_model.dart';
import '../../models/gate_pass_model.dart';
import '../../models/gate_log_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class ScanResultScreen extends StatefulWidget {
  final String studentId;

  const ScanResultScreen({super.key, required this.studentId});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = true;
  bool _isActioning = false;
  StudentModel? _student;
  List<LeaveApplication> _activeLeaves = [];
  List<GatePassModel> _activeGatePasses = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final student = await _firestoreService.getStudent(widget.studentId);
      if (student == null) {
        setState(() {
          _errorMessage = 'Student not found in the system.';
          _isLoading = false;
        });
        return;
      }

      final leaves = await _firestoreService.getActiveLeaves(widget.studentId);
      final gatePasses =
          await _firestoreService.getActiveGatePasses(widget.studentId);

      setState(() {
        _student = student;
        _activeLeaves = leaves;
        _activeGatePasses = gatePasses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _markExit(String passType, String passId, String studentName,
      String roomNumber) async {
    setState(() => _isActioning = true);
    try {
      final uid = context.read<AuthProvider>().uid ?? 'unknown';
      final now = DateTime.now();

      // Update the leave/gate_pass document
      final collection =
          passType == 'leave' ? 'leave_applications' : 'gate_passes';
      if (passType == 'leave') {
        await _firestoreService.updateLeave(passId, {
          'gateStatus': 'out',
          'gateExitTime': Timestamp.fromDate(now),
          'gateVerifiedBy': uid,
        });
      } else {
        await _firestoreService.updateGatePass(passId, {
          'gateStatus': 'out',
          'gateExitTime': Timestamp.fromDate(now),
          'gateVerifiedBy': uid,
        });
      }

      // Create a gate log entry
      await _firestoreService.addGateLog(GateLogModel(
        id: '',
        studentId: widget.studentId,
        studentName: studentName,
        roomNumber: roomNumber,
        action: 'exit',
        passType: passType,
        passId: passId,
        scannedBy: uid,
        scannedAt: now,
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$studentName marked as EXITED'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isActioning = false);
    }
  }

  Future<void> _markReturn(String passType, String passId, String studentName,
      String roomNumber) async {
    setState(() => _isActioning = true);
    try {
      final uid = context.read<AuthProvider>().uid ?? 'unknown';
      final now = DateTime.now();

      if (passType == 'leave') {
        await _firestoreService.updateLeave(passId, {
          'gateStatus': 'in',
          'gateReturnTime': Timestamp.fromDate(now),
        });
      } else {
        await _firestoreService.updateGatePass(passId, {
          'gateStatus': 'in',
          'gateReturnTime': Timestamp.fromDate(now),
          'actualReturnDate': Timestamp.fromDate(now),
        });
      }

      await _firestoreService.addGateLog(GateLogModel(
        id: '',
        studentId: widget.studentId,
        studentName: studentName,
        roomNumber: roomNumber,
        action: 'return',
        passType: passType,
        passId: passId,
        scannedBy: uid,
        scannedAt: now,
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$studentName marked as RETURNED'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isActioning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Result')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildError()
              : _buildResult(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back')),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final student = _student!;
    final hasLeave = _activeLeaves.isNotEmpty;
    final hasGatePass = _activeGatePasses.isNotEmpty;
    final hasValidPass = hasLeave || hasGatePass;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Student Profile Card
          _buildStudentCard(student),
          const SizedBox(height: 16),

          if (!hasValidPass) ...[
            // No valid pass
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.block, size: 48, color: Colors.red.shade700),
                    const SizedBox(height: 12),
                    Text(
                      'NO APPROVED LEAVE / GATE PASS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This student does not have any approved leave or gate pass for today. Do NOT allow exit.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Active Leaves
          if (hasLeave) ...[
            const _SectionHeader(title: 'Approved Leave(s)'),
            ..._activeLeaves.map((leave) => _buildLeaveCard(leave, student)),
          ],

          // Active Gate Passes
          if (hasGatePass) ...[
            const _SectionHeader(title: 'Approved Gate Pass(es)'),
            ..._activeGatePasses
                .map((pass) => _buildGatePassCard(pass, student)),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentCard(StudentModel student) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              backgroundImage: student.profileImageUrl != null
                  ? NetworkImage(student.profileImageUrl!)
                  : null,
              child: student.profileImageUrl == null
                  ? Text(
                      student.name.isNotEmpty
                          ? student.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${student.rollNumber} • ${student.department}',
                      style: TextStyle(color: Colors.grey.shade600)),
                  Text('Room ${student.roomNumber} • ${student.hostelBlock}',
                      style: TextStyle(color: Colors.grey.shade600)),
                  Text('Year: ${student.year} • ${student.branch}',
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveCard(LeaveApplication leave, StudentModel student) {
    final isOut = leave.gateStatus == 'out';
    final isIn = leave.gateStatus == 'in';
    final notScannedYet = leave.gateStatus == null;
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    // Check if return is late
    bool isLate = false;
    if (isOut) {
      final now = DateTime.now();
      if (now.isAfter(leave.toDate.add(const Duration(days: 1)))) {
        isLate = true;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isLate
              ? Colors.red
              : isOut
                  ? Colors.orange
                  : isIn
                      ? Colors.green
                      : Colors.blue,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLate
                        ? Colors.red.shade100
                        : isOut
                            ? Colors.orange.shade100
                            : isIn
                                ? Colors.green.shade100
                                : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isLate
                        ? 'LATE RETURN'
                        : isOut
                            ? 'CURRENTLY OUT'
                            : isIn
                                ? 'RETURNED'
                                : 'NOT EXITED YET',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isLate
                          ? Colors.red.shade700
                          : isOut
                              ? Colors.orange.shade700
                              : isIn
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                Text('Leave',
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const Divider(),
            _InfoRow('Type', leave.leaveType),
            _InfoRow('Reason', leave.leaveReason),
            _InfoRow('Destination', leave.destination),
            _InfoRow('From',
                '${dateFormat.format(leave.fromDate)}${leave.fromTime != null ? ' at ${leave.fromTime}' : ''}'),
            _InfoRow('To',
                '${dateFormat.format(leave.toDate)}${leave.toTime != null ? ' at ${leave.toTime}' : ''}'),
            _InfoRow('Transport', leave.modeOfTransport),
            if (leave.parentPhone != null)
              _InfoRow('Parent Phone', leave.parentPhone!),
            if (leave.description.isNotEmpty)
              _InfoRow('Description', leave.description),
            if (leave.gateExitTime != null)
              _InfoRow('Exit Time',
                  '${dateFormat.format(leave.gateExitTime!)} at ${timeFormat.format(leave.gateExitTime!)}'),
            if (leave.gateReturnTime != null)
              _InfoRow('Return Time',
                  '${dateFormat.format(leave.gateReturnTime!)} at ${timeFormat.format(leave.gateReturnTime!)}'),
            const SizedBox(height: 12),

            // Action buttons
            if (notScannedYet)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isActioning
                      ? null
                      : () => _markExit('leave', leave.id, student.name,
                          student.roomNumber),
                  icon: const Icon(Icons.logout),
                  label: _isActioning
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Allow Exit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

            if (isOut)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isActioning
                      ? null
                      : () => _markReturn('leave', leave.id, student.name,
                          student.roomNumber),
                  icon: const Icon(Icons.login),
                  label: _isActioning
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Mark Return'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLate ? Colors.red : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

            if (isIn)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text('Student has returned',
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGatePassCard(GatePassModel pass, StudentModel student) {
    final isOut = pass.gateStatus == 'out';
    final isIn = pass.gateStatus == 'in';
    final notScannedYet = pass.gateStatus == null;
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    bool isLate = false;
    if (isOut) {
      final now = DateTime.now();
      if (now.isAfter(
          pass.expectedReturnDate.add(const Duration(days: 1)))) {
        isLate = true;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isLate
              ? Colors.red
              : isOut
                  ? Colors.orange
                  : isIn
                      ? Colors.green
                      : Colors.blue,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLate
                        ? Colors.red.shade100
                        : isOut
                            ? Colors.orange.shade100
                            : isIn
                                ? Colors.green.shade100
                                : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isLate
                        ? 'LATE RETURN'
                        : isOut
                            ? 'CURRENTLY OUT'
                            : isIn
                                ? 'RETURNED'
                                : 'NOT EXITED YET',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isLate
                          ? Colors.red.shade700
                          : isOut
                              ? Colors.orange.shade700
                              : isIn
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                Text('Gate Pass',
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const Divider(),
            _InfoRow('Reason', pass.reason),
            _InfoRow('Destination', pass.destination),
            _InfoRow('Out Date', dateFormat.format(pass.outDate)),
            _InfoRow(
                'Expected Return', dateFormat.format(pass.expectedReturnDate)),
            if (pass.wardenRemarks != null)
              _InfoRow('Warden Remarks', pass.wardenRemarks!),
            if (pass.gateExitTime != null)
              _InfoRow('Exit Time',
                  '${dateFormat.format(pass.gateExitTime!)} at ${timeFormat.format(pass.gateExitTime!)}'),
            if (pass.gateReturnTime != null)
              _InfoRow('Return Time',
                  '${dateFormat.format(pass.gateReturnTime!)} at ${timeFormat.format(pass.gateReturnTime!)}'),
            const SizedBox(height: 12),

            if (notScannedYet)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isActioning
                      ? null
                      : () => _markExit('gate_pass', pass.id, student.name,
                          student.roomNumber),
                  icon: const Icon(Icons.logout),
                  label: _isActioning
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Allow Exit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

            if (isOut)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isActioning
                      ? null
                      : () => _markReturn('gate_pass', pass.id, student.name,
                          student.roomNumber),
                  icon: const Icon(Icons.login),
                  label: _isActioning
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Mark Return'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLate ? Colors.red : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

            if (isIn)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text('Student has returned',
                        style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
