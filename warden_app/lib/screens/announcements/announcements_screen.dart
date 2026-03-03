import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../models/announcement_model.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Announcements',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showPostAnnouncementDialog(context, data),
                icon: const Icon(Icons.campaign),
                label: const Text('Post Announcement'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: data.announcements.isEmpty
                ? const Center(
                    child: Text('No announcements yet',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: data.announcements.length,
                    itemBuilder: (context, index) {
                      final ann = data.announcements[index];
                      return _AnnouncementCard(
                        announcement: ann,
                        onDelete: () => data.deleteAnnouncement(ann.id),
                        onEdit: () => _showEditDialog(context, data, ann),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showPostAnnouncementDialog(BuildContext context, DataProvider data) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String category = 'general';
    bool isUrgent = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Post Announcement'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentCtrl,
                    maxLines: 5,
                    decoration: const InputDecoration(
                        labelText: 'Content', alignLabelWithHint: true),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: ['general', 'urgent', 'event', 'maintenance']
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child:
                                Text(c[0].toUpperCase() + c.substring(1))))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => category = v!),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Mark as Urgent'),
                    value: isUrgent,
                    onChanged: (v) =>
                        setDialogState(() => isUrgent = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) return;
                final ann = AnnouncementModel(
                  id: '',
                  title: titleCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  category: category,
                  postedBy: 'warden',
                  postedByName: 'Warden',
                  isUrgent: isUrgent,
                  createdAt: DateTime.now(),
                );
                await data.addAnnouncement(ann);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, DataProvider data, AnnouncementModel ann) {
    final titleCtrl = TextEditingController(text: ann.title);
    final contentCtrl = TextEditingController(text: ann.content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Announcement'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                    labelText: 'Content', alignLabelWithHint: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await data.updateAnnouncement(ann.id, {
                'title': titleCtrl.text.trim(),
                'content': contentCtrl.text.trim(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  const _AnnouncementCard(
      {required this.announcement,
      required this.onDelete,
      required this.onEdit});

  Color get _categoryColor {
    switch (announcement.category) {
      case 'urgent':
        return Colors.red;
      case 'event':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'general':
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    announcement.category.toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _categoryColor),
                  ),
                ),
                if (announcement.isUrgent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('URGENT',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.red)),
                  ),
                ],
                const Spacer(),
                Text(_formatDate(announcement.createdAt),
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(width: 8),
                IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: onEdit),
                IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: onDelete),
              ],
            ),
            const SizedBox(height: 8),
            Text(announcement.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(announcement.content,
                style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Text('Posted by: ${announcement.postedByName}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
