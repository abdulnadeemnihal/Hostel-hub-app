import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/complaint_model.dart';
import '../../utils/constants.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTicketScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: data.complaints.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tickets',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  Text(
                    'Tap + to raise a ticket',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.complaints.length,
              itemBuilder: (context, index) {
                final c = data.complaints[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                c.category,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Chip(
                              label: Text(
                                c.subCategory,
                                style: const TextStyle(fontSize: 11),
                              ),
                              backgroundColor: Colors.blue.shade50,
                            ),
                            const Spacer(),
                            _StatusChip(status: c.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _UrgencyBadge(urgency: c.urgency),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${c.category} - ${c.subCategory}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c.description,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Raised on: ${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        if (c.response != null) ...[
                          const Divider(),
                          Text(
                            'Response: ${c.response}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        // Edit & Delete only when status is pending
                        if (c.status == 'pending') ...[
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditTicketScreen(complaint: c),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () => _confirmDelete(context, c.id),
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text('Delete'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmDelete(BuildContext context, String complaintId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Ticket'),
        content: const Text('Are you sure you want to delete this ticket?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<DataProvider>().deleteComplaint(complaintId);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ticket deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Add Ticket Screen (Full Page Form) ───
class AddTicketScreen extends StatefulWidget {
  const AddTicketScreen({super.key});

  @override
  State<AddTicketScreen> createState() => _AddTicketScreenState();
}

class _AddTicketScreenState extends State<AddTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();

  String _selectedCategory = AppConstants.complaintCategories.first;
  String? _selectedSubCategory;
  String _selectedUrgency = 'Basic';
  final List<XFile> _selectedPhotos = [];
  bool _isSubmitting = false;

  List<String> get _subCategories =>
      AppConstants.complaintSubCategories[_selectedCategory] ?? [];

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (images.isNotEmpty) {
      setState(() {
        for (final img in images) {
          // Only allow up to 5MB files
          _selectedPhotos.add(img);
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a sub-category')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final student = auth.student;
    if (student == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    final complaint = ComplaintModel(
      id: '',
      studentId: student.uid,
      studentName: student.name,
      roomNumber: student.roomNumber,
      category: _selectedCategory,
      subCategory: _selectedSubCategory!,
      urgency: _selectedUrgency,
      description: _descriptionCtrl.text.trim(),
      status: 'pending',
      photos: [],
      createdAt: DateTime.now(),
    );

    await context.read<DataProvider>().addComplaint(complaint);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket raised successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text('Add Ticket'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // ── Category ──
            _buildLabel('Category*'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: _inputDecoration(),
              items: AppConstants.complaintCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _selectedCategory = v!;
                  _selectedSubCategory = null;
                });
              },
              validator: (v) => v == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),

            // ── Sub Category ──
            _buildLabel('Sub Category*'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedSubCategory,
              decoration: _inputDecoration(),
              hint: const Text('Select sub-category'),
              items: _subCategories
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedSubCategory = v),
              validator: (v) =>
                  v == null ? 'Please select a sub-category' : null,
            ),
            const SizedBox(height: 20),

            // ── Urgency ──
            _buildLabel('Urgency*'),
            const SizedBox(height: 10),
            _UrgencySelector(
              selected: _selectedUrgency,
              onChanged: (v) => setState(() => _selectedUrgency = v),
            ),
            const SizedBox(height: 20),

            // ── Photos ──
            _buildLabel('Photos'),
            const SizedBox(height: 4),
            const Text(
              '*Files upto 5MB in size are allowed',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
            const SizedBox(height: 8),
            _PhotosPicker(
              photos: _selectedPhotos,
              onAdd: _pickPhotos,
              onRemove: (i) => setState(() => _selectedPhotos.removeAt(i)),
            ),
            const SizedBox(height: 20),

            // ── Description ──
            _buildLabel('Description*'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descriptionCtrl,
              maxLines: 5,
              decoration: _inputDecoration(hint: 'Enter Description*'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter a description'
                  : null,
            ),
            const SizedBox(height: 32),

            // ── Submit ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF555555),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

// ─── Urgency Selector (Segmented) ───
class _UrgencySelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _UrgencySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppConstants.urgencyLevels.map((level) {
        final isSelected = selected == level;
        final color = _urgencyColor(level);
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(level),
            child: Container(
              margin: EdgeInsets.only(
                right: level != AppConstants.urgencyLevels.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                level,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _urgencyColor(String level) {
    switch (level) {
      case 'Basic':
        return const Color(0xFF6366F1);
      case 'Medium':
        return Colors.orange;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// ─── Photos Picker Widget ───
class _PhotosPicker extends StatelessWidget {
  final List<XFile> photos;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  const _PhotosPicker({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (photos.isNotEmpty) ...[
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(photos[i].path),
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => onRemove(i),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
        InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Photos',
                  style: TextStyle(color: Colors.grey[700], fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Status Chip ───
class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'pending': Colors.orange,
      'processing': Colors.blue,
      'fixed': Colors.green,
    };
    final labels = {
      'pending': 'PENDING',
      'processing': 'PROCESSING',
      'fixed': 'FIXED',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (colors[status] ?? Colors.grey).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        labels[status] ?? status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: colors[status] ?? Colors.grey,
        ),
      ),
    );
  }
}

// ─── Urgency Badge ───
class _UrgencyBadge extends StatelessWidget {
  final String urgency;
  const _UrgencyBadge({required this.urgency});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'Basic': const Color(0xFF6366F1),
      'Medium': Colors.orange,
      'Critical': Colors.red,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (colors[urgency] ?? Colors.grey).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        urgency,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors[urgency] ?? Colors.grey,
        ),
      ),
    );
  }
}

// ─── Edit Ticket Screen ───
class EditTicketScreen extends StatefulWidget {
  final ComplaintModel complaint;
  const EditTicketScreen({super.key, required this.complaint});

  @override
  State<EditTicketScreen> createState() => _EditTicketScreenState();
}

class _EditTicketScreenState extends State<EditTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionCtrl;

  late String _selectedCategory;
  String? _selectedSubCategory;
  late String _selectedUrgency;
  bool _isSubmitting = false;

  List<String> get _subCategories =>
      AppConstants.complaintSubCategories[_selectedCategory] ?? [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.complaint.category;
    _selectedSubCategory = widget.complaint.subCategory.isNotEmpty
        ? widget.complaint.subCategory
        : null;
    _selectedUrgency = widget.complaint.urgency;
    _descriptionCtrl = TextEditingController(
      text: widget.complaint.description,
    );
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a sub-category')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    await context.read<DataProvider>().updateComplaint(widget.complaint.id, {
      'category': _selectedCategory,
      'subCategory': _selectedSubCategory,
      'urgency': _selectedUrgency,
      'description': _descriptionCtrl.text.trim(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        title: const Text('Edit Ticket'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // ── Category ──
            _buildLabel('Category*'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: _inputDecoration(),
              items: AppConstants.complaintCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _selectedCategory = v!;
                  _selectedSubCategory = null;
                });
              },
              validator: (v) => v == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),

            // ── Sub Category ──
            _buildLabel('Sub Category*'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _subCategories.contains(_selectedSubCategory)
                  ? _selectedSubCategory
                  : null,
              decoration: _inputDecoration(),
              hint: const Text('Select sub-category'),
              items: _subCategories
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedSubCategory = v),
              validator: (v) =>
                  v == null ? 'Please select a sub-category' : null,
            ),
            const SizedBox(height: 20),

            // ── Urgency ──
            _buildLabel('Urgency*'),
            const SizedBox(height: 10),
            _UrgencySelector(
              selected: _selectedUrgency,
              onChanged: (v) => setState(() => _selectedUrgency = v),
            ),
            const SizedBox(height: 20),

            // ── Description ──
            _buildLabel('Description*'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descriptionCtrl,
              maxLines: 5,
              decoration: _inputDecoration(hint: 'Enter Description*'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter a description'
                  : null,
            ),
            const SizedBox(height: 32),

            // ── Submit ──
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Update',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF555555),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}
