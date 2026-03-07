import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../models/meal_poll_model.dart';

class BookMealScreen extends StatelessWidget {
  const BookMealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final auth = context.watch<AuthProvider>();
    final studentId = auth.student?.uid ?? '';
    final foodPref = auth.student?.foodPreference ?? 'Vegetarian';

    final activePolls = data.activePolls
        .where((p) => p.isActive && (p.foodType == foodPref || p.foodType == 'Both'))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Book a Meal')),
      body: activePolls.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.poll_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No active polls',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Warden will publish meal polls here',
                      style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activePolls.length,
              itemBuilder: (context, index) {
                final poll = activePolls[index];
                return _StudentPollCard(
                  poll: poll,
                  studentId: studentId,
                  onVote: (optionIndex) {
                    data.submitVote(poll.id, studentId, optionIndex);
                  },
                );
              },
            ),
    );
  }
}

class _StudentPollCard extends StatefulWidget {
  final MealPoll poll;
  final String studentId;
  final void Function(int optionIndex) onVote;

  const _StudentPollCard({
    required this.poll,
    required this.studentId,
    required this.onVote,
  });

  @override
  State<_StudentPollCard> createState() => _StudentPollCardState();
}

class _StudentPollCardState extends State<_StudentPollCard> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final hasVoted = widget.poll.voters.containsKey(widget.studentId);
    final votedIndex = hasVoted ? widget.poll.voters[widget.studentId] : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.indigo.shade200, width: 1.5),
      ),
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              children: [
                const Icon(Icons.poll, color: Colors.indigo, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.poll.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                _timerBadge(),
              ],
            ),
            const SizedBox(height: 6),

            // ── Meta ──
            Wrap(
              spacing: 8,
              children: [
                _metaChip(widget.poll.targetDay, Colors.blue),
                _metaChip(widget.poll.mealType, Colors.orange),
              ],
            ),
            const SizedBox(height: 12),

            // ── Options ──
            ...List.generate(widget.poll.options.length, (i) {
              final opt = widget.poll.options[i];

              if (hasVoted) {
                final isSelected = votedIndex == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? Colors.indigo.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.indigo.shade300
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 18,
                          color: isSelected
                              ? Colors.indigo
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 10),
                        Text(opt.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color:
                                  isSelected ? Colors.indigo : Colors.black87,
                            )),
                      ],
                    ),
                  ),
                );
              } else {
                final isSelected = _selectedIndex == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => setState(() => _selectedIndex = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.indigo.shade50
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? Colors.indigo.shade300
                              : Colors.indigo.shade100,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 18,
                            color: isSelected
                                ? Colors.indigo
                                : Colors.indigo.shade300,
                          ),
                          const SizedBox(width: 10),
                          Text(opt.name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }),

            // ── Submit Button ──
            if (!hasVoted) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selectedIndex != null
                      ? () => widget.onVote(_selectedIndex!)
                      : null,
                  icon: const Icon(Icons.how_to_vote, size: 18),
                  label: const Text('Submit Vote'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],

            // ── Footer ──
            if (hasVoted) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.check_circle,
                      size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('You have voted!',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timerBadge() {
    final remaining = widget.poll.expiresAt.difference(DateTime.now());
    if (remaining.isNegative) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Ending...',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
      );
    }
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final label = h >= 24 ? '${h ~/ 24}d ${h % 24}h' : '${h}h ${m}m';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.indigo.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, size: 12, color: Colors.indigo),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo)),
        ],
      ),
    );
  }

  Widget _metaChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
