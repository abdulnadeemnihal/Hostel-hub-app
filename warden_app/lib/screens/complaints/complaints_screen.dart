import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../utils/constants.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  String _filterStatus = 'all';
  String _filterCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    var filtered = data.complaints;
    if (_filterStatus != 'all') {
      filtered = filtered.where((c) => c.status == _filterStatus).toList();
    }
    if (_filterCategory != 'all') {
      filtered = filtered.where((c) => c.category == _filterCategory).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tickets',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // ── Status Filter ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _filterStatus == 'all',
                  onTap: () => setState(() => _filterStatus = 'all'),
                ),
                _FilterChip(
                  label: 'Pending',
                  isSelected: _filterStatus == 'pending',
                  color: Colors.orange,
                  onTap: () => setState(() => _filterStatus = 'pending'),
                ),
                _FilterChip(
                  label: 'Processing',
                  isSelected: _filterStatus == 'processing',
                  color: Colors.blue,
                  onTap: () => setState(() => _filterStatus = 'processing'),
                ),
                _FilterChip(
                  label: 'Fixed',
                  isSelected: _filterStatus == 'fixed',
                  color: Colors.green,
                  onTap: () => setState(() => _filterStatus = 'fixed'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Category Filter ──
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All Categories',
                  isSelected: _filterCategory == 'all',
                  onTap: () => setState(() => _filterCategory = 'all'),
                ),
                ...AppConstants.complaintCategories.map(
                  (cat) => _FilterChip(
                    label: cat,
                    isSelected: _filterCategory == cat,
                    onTap: () => setState(() => _filterCategory = cat),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Ticket List ──
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No tickets',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final c = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: _statusDot(c.status),
                          title: Text(
                            '${c.category} - ${c.subCategory}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${c.studentName} • Room ${c.roomNumber} • ${c.urgency}',
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Info rows
                                  _InfoRow(
                                    label: 'Category',
                                    value: c.category,
                                  ),
                                  _InfoRow(
                                    label: 'Sub-Category',
                                    value: c.subCategory,
                                  ),
                                  _InfoRow(label: 'Urgency', value: c.urgency),
                                  const SizedBox(height: 8),
                                  Text(c.description),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Submitted: ${c.createdAt.day}/${c.createdAt.month}/${c.createdAt.year}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (c.resolvedAt != null)
                                    Text(
                                      'Fixed on: ${c.resolvedAt!.day}/${c.resolvedAt!.month}/${c.resolvedAt!.year}',
                                      style: TextStyle(
                                        color: Colors.green[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  const SizedBox(height: 16),

                                  // ── Status Update Section ──
                                  const Text(
                                    'Update Status',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (c.status == 'pending') ...[
                                        ElevatedButton.icon(
                                          onPressed: () =>
                                              _updateStatus(c.id, 'processing'),
                                          icon: const Icon(
                                            Icons.play_arrow,
                                            size: 18,
                                          ),
                                          label: const Text('Processing'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      if (c.status == 'processing') ...[
                                        ElevatedButton.icon(
                                          onPressed: () => _showFixDialog(c.id),
                                          icon: const Icon(
                                            Icons.check_circle,
                                            size: 18,
                                          ),
                                          label: const Text('Fixed'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      if (c.status == 'pending') ...[
                                        ElevatedButton.icon(
                                          onPressed: () => _showFixDialog(c.id),
                                          icon: const Icon(
                                            Icons.check,
                                            size: 18,
                                          ),
                                          label: const Text('Fixed'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (c.response != null &&
                                      c.response!.isNotEmpty) ...[
                                    const Divider(),
                                    Text(
                                      'Response: ${c.response}',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statusDot(String status) {
    final colors = {
      'pending': Colors.orange,
      'processing': Colors.blue,
      'fixed': Colors.green,
    };
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors[status] ?? Colors.grey,
      ),
    );
  }

  void _updateStatus(String id, String status) {
    context.read<DataProvider>().updateComplaint(id, status, null);
  }

  void _showFixDialog(String id) {
    final responseCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as Fixed'),
        content: TextField(
          controller: responseCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Response/Resolution (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DataProvider>().updateComplaint(
                id,
                'fixed',
                responseCtrl.text.isNotEmpty ? responseCtrl.text : null,
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text(
              'Mark Fixed',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Chip ───
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: (color ?? const Color(0xFF6366F1)).withValues(
          alpha: 0.2,
        ),
        checkmarkColor: color ?? const Color(0xFF6366F1),
        labelStyle: TextStyle(
          color: isSelected
              ? (color ?? const Color(0xFF6366F1))
              : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

// ─── Info Row ───
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Text(': ', style: TextStyle(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
