import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/leave_model.dart';
import '../../utils/constants.dart';

// ═════════════════════════════════════════════════════════════════════════════
// 1) APPLY LEAVE SCREEN  (Quick Action → opens form directly)
// ═════════════════════════════════════════════════════════════════════════════

class ApplyLeaveScreen extends StatefulWidget {
  /// If non-null we are editing an existing leave (pre-fill everything).
  final LeaveApplication? existingLeave;
  const ApplyLeaveScreen({super.key, this.existingLeave});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descCtrl;
  late final TextEditingController _destCtrl;

  late String _leaveType;
  late String _leaveReason;
  late String _transport;

  late DateTime _fromDate;
  late DateTime _toDate;
  late TimeOfDay _fromTime;
  late TimeOfDay _toTime;

  bool _termsAccepted = false;
  bool _isLoading = false;
  bool _showTerms = false;

  bool get _isEditing => widget.existingLeave != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existingLeave;
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _destCtrl = TextEditingController(text: e?.destination ?? '');
    _leaveType = e?.leaveType ?? AppConstants.leaveTypes.first;
    _leaveReason = e?.leaveReason ?? AppConstants.leaveReasons.first;
    _transport = e?.modeOfTransport ?? AppConstants.modesOfTransport.first;
    _fromDate = e?.fromDate ?? DateTime.now();
    _toDate = e?.toDate ?? DateTime.now().add(const Duration(days: 1));
    _fromTime = e != null && e.fromTime != null
        ? _parseTime(e.fromTime!)
        : const TimeOfDay(hour: 9, minute: 0);
    _toTime = e != null && e.toTime != null
        ? _parseTime(e.toTime!)
        : const TimeOfDay(hour: 18, minute: 0);
    _termsAccepted = e?.termsAccepted ?? false;
  }

  TimeOfDay _parseTime(String t) {
    final parts = t.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _destCtrl.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          if (_toDate.isBefore(_fromDate)) _toDate = _fromDate;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(bool isFrom) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? _fromTime : _toTime,
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromTime = picked;
        } else {
          _toTime = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final student = auth.student;
    if (student == null) {
      setState(() => _isLoading = false);
      return;
    }

    final dp = context.read<DataProvider>();

    if (_isEditing) {
      // ── UPDATE existing leave ──
      await dp.updateLeave(widget.existingLeave!.id, {
        'leaveType': _leaveType,
        'fromDate': Timestamp.fromDate(_fromDate),
        'toDate': Timestamp.fromDate(_toDate),
        'fromTime': _formatTime(_fromTime),
        'toTime': _formatTime(_toTime),
        'leaveReason': _leaveReason,
        'destination': _destCtrl.text.trim(),
        'modeOfTransport': _transport,
        'description': _descCtrl.text.trim(),
        'termsAccepted': _termsAccepted,
      });
    } else {
      // ── CREATE new leave ──
      final leave = LeaveApplication(
        id: '',
        studentId: student.uid,
        studentName: student.name,
        roomNumber: student.roomNumber,
        leaveType: _leaveType,
        fromDate: _fromDate,
        toDate: _toDate,
        fromTime: _formatTime(_fromTime),
        toTime: _formatTime(_toTime),
        leaveReason: _leaveReason,
        parentPhone: student.parentPhone,
        destination: _destCtrl.text.trim(),
        modeOfTransport: _transport,
        description: _descCtrl.text.trim(),
        photoUrls: const [],
        termsAccepted: _termsAccepted,
        status: 'pending',
        createdAt: DateTime.now(),
      );
      await dp.addLeave(leave);
    }

    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Leave updated!' : 'Leave application submitted!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = context.read<AuthProvider>().student;
    final parentPhone = student?.parentPhone ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Leave' : 'Apply for Leave'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Leave Type ──
              _sectionLabel('Leave Type'),
              DropdownButtonFormField<String>(
                value: _leaveType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.leaveTypes
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _leaveType = v!),
              ),
              const SizedBox(height: 16),

              // ── From / To Date ──
              _sectionLabel('From Date & To Date'),
              Row(
                children: [
                  Expanded(
                    child: _DateTile(
                      label: 'From',
                      date: _fromDate,
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateTile(
                      label: 'To',
                      date: _toDate,
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── From / To Time ──
              _sectionLabel('From Time & To Time'),
              Row(
                children: [
                  Expanded(
                    child: _TimeTile(
                      label: 'From',
                      time: _fromTime,
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeTile(
                      label: 'To',
                      time: _toTime,
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Leave Reason ──
              _sectionLabel('Leave Reason'),
              DropdownButtonFormField<String>(
                value: _leaveReason,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.help_outline),
                ),
                items: AppConstants.leaveReasons
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _leaveReason = v!),
              ),
              const SizedBox(height: 16),

              // ── Parent Contact (read‑only) ──
              _sectionLabel('Parent Contact'),
              TextFormField(
                initialValue: parentPhone,
                readOnly: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  helperText: 'Auto-filled from your profile',
                ),
              ),
              const SizedBox(height: 16),

              // ── Place to Visit ──
              _sectionLabel('Place to Visit'),
              TextFormField(
                controller: _destCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter destination',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // ── Mode of Transportation ──
              _sectionLabel('Mode of Transportation'),
              DropdownButtonFormField<String>(
                value: _transport,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_bus_outlined),
                ),
                items: AppConstants.modesOfTransport
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _transport = v!),
              ),
              const SizedBox(height: 16),

              // ── Description ──
              _sectionLabel('Description'),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Describe the reason for your leave in detail...',
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // ── Photos (optional) ──
              _sectionLabel('Photos (Optional)'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Photo upload coming soon',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    Text(
                      '(Firebase Storage integration needed)',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Terms & Conditions ──
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.policy_outlined),
                      title: const Text(
                        'Hostel Late Entry Policy',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Terms & Conditions'),
                      trailing: IconButton(
                        icon: Icon(
                          _showTerms ? Icons.expand_less : Icons.expand_more,
                        ),
                        onPressed: () =>
                            setState(() => _showTerms = !_showTerms),
                      ),
                    ),
                    if (_showTerms)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: _TermsContent(),
                      ),
                    CheckboxListTile(
                      value: _termsAccepted,
                      onChanged: (v) =>
                          setState(() => _termsAccepted = v ?? false),
                      title: const Text(
                        'I have read and agree to the Hostel Late Entry Policy – Terms & Conditions',
                        style: TextStyle(fontSize: 13),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Submit ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _isLoading
                        ? 'Submitting...'
                        : _isEditing
                        ? 'Update Leave'
                        : 'Submit Leave Application',
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 2) LEAVE MANAGER SCREEN  (Apps grid → leave history with edit / delete)
// ═════════════════════════════════════════════════════════════════════════════

class LeaveManagerScreen extends StatelessWidget {
  const LeaveManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Manager')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ApplyLeaveScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Leave'),
      ),
      body: data.leaves.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No leave records',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Your leave history will appear here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.leaves.length,
              itemBuilder: (context, index) {
                final l = data.leaves[index];
                return _LeaveCard(leave: l);
              },
            ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveApplication leave;
  const _LeaveCard({required this.leave});

  @override
  Widget build(BuildContext context) {
    final statusColor =
        {
          'pending': Colors.orange,
          'approved': Colors.green,
          'rejected': Colors.red,
        }[leave.status] ??
        Colors.grey;

    final canEdit = leave.status == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => _LeaveDetailScreen(leave: leave)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──
              Row(
                children: [
                  Chip(
                    label: Text(
                      leave.leaveType,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Chip(
                    label: Text(
                      leave.leaveReason,
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      leave.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Description preview ──
              Text(
                leave.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),

              // ── Date range ──
              Text(
                '${DateFormat('dd MMM').format(leave.fromDate)}'
                ' → ${DateFormat('dd MMM yyyy').format(leave.toDate)}'
                '  (${leave.leaveDays} days)',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),

              // ── Location & transport ──
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    leave.destination,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.directions_bus_outlined,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    leave.modeOfTransport,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),

              // ── Warden remarks ──
              if (leave.wardenRemarks != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Remarks: ${leave.wardenRemarks}',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              // ── Edit / Delete actions (only for pending) ──
              if (canEdit) ...[
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ApplyLeaveScreen(existingLeave: leave),
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _confirmDelete(context, leave),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, LeaveApplication leave) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Leave'),
        content: const Text(
          'Are you sure you want to delete this leave application? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<DataProvider>().deleteLeave(leave.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Leave application deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// 3) LEAVE DETAIL SCREEN
// ═════════════════════════════════════════════════════════════════════════════

class _LeaveDetailScreen extends StatelessWidget {
  final LeaveApplication leave;
  const _LeaveDetailScreen({required this.leave});

  @override
  Widget build(BuildContext context) {
    final statusColor =
        {
          'pending': Colors.orange,
          'approved': Colors.green,
          'rejected': Colors.red,
        }[leave.status] ??
        Colors.grey;
    final canEdit = leave.status == 'pending';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Details'),
        actions: canEdit
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit',
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApplyLeaveScreen(existingLeave: leave),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Leave'),
                        content: const Text('Delete this leave application?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await context.read<DataProvider>().deleteLeave(
                                leave.id,
                              );
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    leave.status == 'approved'
                        ? Icons.check_circle
                        : leave.status == 'rejected'
                        ? Icons.cancel
                        : Icons.hourglass_empty,
                    color: statusColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    leave.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _detailCard('Leave Information', [
              _row('Leave Type', leave.leaveType),
              _row('Leave Reason', leave.leaveReason),
              _row(
                'From Date',
                DateFormat('dd MMM yyyy').format(leave.fromDate),
              ),
              _row('To Date', DateFormat('dd MMM yyyy').format(leave.toDate)),
              if (leave.fromTime != null) _row('From Time', leave.fromTime!),
              if (leave.toTime != null) _row('To Time', leave.toTime!),
              _row('Total Days', '${leave.leaveDays} days'),
            ]),
            const SizedBox(height: 12),
            _detailCard('Travel Details', [
              _row('Place to Visit', leave.destination),
              _row('Mode of Transport', leave.modeOfTransport),
            ]),
            const SizedBox(height: 12),
            _detailCard('Contact', [
              _row('Parent Phone', leave.parentPhone ?? 'N/A'),
            ]),
            const SizedBox(height: 12),
            _detailCard('Description', [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  leave.description,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ]),
            if (leave.wardenRemarks != null) ...[
              const SizedBox(height: 12),
              _detailCard('Warden Remarks', [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    leave.wardenRemarks!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ]),
            ],
            if (leave.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Attached Photos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: leave.photoUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      leave.photoUrls[i],
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// HELPER WIDGETS
// ═════════════════════════════════════════════════════════════════════════════

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = time.format(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                Text(
                  formatted,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TERMS & CONDITIONS CONTENT
// ═════════════════════════════════════════════════════════════════════════════

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TH('1. Hostel Entry Timings'),
        _TP(
          'All hostel residents must return to the hostel premises before the designated entry time set by the hostel administration. The standard entry timing is 9:00 PM unless otherwise notified by the warden.',
        ),
        _TH('2. Late Entry Definition'),
        _TP(
          'A student will be considered "late" if they enter the hostel premises after the official closing time without prior written or digital permission from the warden.',
        ),
        _TH('3. Permission for Late Entry'),
        _TP(
          'Students who anticipate returning late must:\n'
          '• Inform the warden in advance.\n'
          '• Submit a valid reason through the hostel app or written application.\n'
          '• Obtain explicit approval before the closing time.\n\n'
          'Failure to obtain prior approval will be treated as a policy violation.',
        ),
        _TH('4. Consequences of Late Entry'),
        _TP(
          'If a student enters the hostel late without prior approval, the following actions may be taken:\n\n'
          'First Violation:\n'
          '• Verbal warning and record entry in hostel log.\n\n'
          'Second Violation:\n'
          '• Written warning issued to the student.\n'
          '• Notification sent to parent/guardian.\n\n'
          'Third Violation:\n'
          '• Monetary fine (as determined by administration).\n'
          '• Mandatory meeting with warden and hostel committee.\n\n'
          'Repeated Violations:\n'
          '• Disciplinary action which may include suspension from hostel facilities or cancellation of hostel accommodation, subject to administrative review.',
        ),
        _TH('5. Emergency Situations'),
        _TP(
          'In case of genuine emergencies (medical, academic, travel delay, etc.), students must:\n'
          '• Inform the warden immediately via call or app.\n'
          '• Provide supporting documentation if required.\n\n'
          'Emergency cases will be reviewed at the discretion of hostel authorities.',
        ),
        _TH('6. Safety Responsibility'),
        _TP(
          'The hostel administration prioritizes student safety. Students entering late do so at their own responsibility, and repeated violations may be treated as misconduct.',
        ),
        _TH('7. Record Maintenance'),
        _TP(
          'All late entries will be digitally recorded in the hostel management system and may be reviewed periodically.',
        ),
        _TH('8. Policy Updates'),
        _TP(
          'The hostel administration reserves the right to modify entry timings or disciplinary measures at any time. Students will be notified through official communication channels.',
        ),
        SizedBox(height: 8),
        Divider(),
        _TP(
          'By residing in the hostel, the student agrees to comply with the above late entry rules and acknowledges that violations may result in disciplinary action.',
        ),
      ],
    );
  }
}

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _TP extends StatelessWidget {
  final String text;
  const _TP(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5),
    );
  }
}
