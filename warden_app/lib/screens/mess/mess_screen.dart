import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../models/meal_model.dart';
import '../../models/meal_poll_model.dart';
import '../../utils/constants.dart';

class MessScreen extends StatefulWidget {
  const MessScreen({super.key});

  @override
  State<MessScreen> createState() => _MessScreenState();
}

class _MessScreenState extends State<MessScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDay = AppConstants.daysOfWeek[DateTime.now().weekday - 1];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _currentFoodType {
    if (_tabController.index == 0) return 'Vegetarian';
    if (_tabController.index == 1) return 'Non-Vegetarian';
    return 'Vegetarian'; // fallback for Polls tab
  }

  bool get _isPollsTab => _tabController.index == 2;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final vegCount =
        data.students.where((s) => s.foodPreference == 'Vegetarian').length;
    final nonVegCount =
        data.students.where((s) => s.foodPreference == 'Non-Vegetarian').length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              const Text('Mess Menu Management',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_isPollsTab)
                ElevatedButton.icon(
                  onPressed: () => _showCreatePollDialog(context, data),
                  icon: const Icon(Icons.poll),
                  label: const Text('Create Poll'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => _showAddMenuDialog(context, data),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Menu'),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Student Count Summary ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, size: 20, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  'Students:  ',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.blueGrey[700]),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.eco, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text('$vegCount Veg',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.restaurant,
                          size: 14, color: Colors.deepOrange),
                      const SizedBox(width: 4),
                      Text('$nonVegCount Non-Veg',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Veg / Non-Veg Tabs ──
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              onTap: (_) => setState(() {}),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[700],
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: _tabController.index == 0
                    ? Colors.green
                    : _tabController.index == 1
                        ? Colors.deepOrange
                        : Colors.indigo,
                borderRadius: BorderRadius.circular(12),
              ),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco, size: 18),
                      SizedBox(width: 6),
                      Text('Veg',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant, size: 18),
                      SizedBox(width: 6),
                      Text('Non-Veg',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.poll, size: 18),
                      SizedBox(width: 6),
                      Text('Polls',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Day Chips (hidden on Polls tab) ──
          if (!_isPollsTab) ...[
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.daysOfWeek.length,
                itemBuilder: (context, index) {
                  final day = AppConstants.daysOfWeek[index];
                  final selected = day == _selectedDay;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(day.substring(0, 3)),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedDay = day),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Meal Cards / Polls ──
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMealList(data, 'Vegetarian'),
                _buildMealList(data, 'Non-Vegetarian'),
                _buildPollsList(data),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealList(DataProvider data, String foodType) {
    final mealsForDay = data.meals
        .where((m) => m.day == _selectedDay && m.foodType == foodType)
        .toList();

    if (mealsForDay.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text('No $foodType menu for $_selectedDay',
                style: TextStyle(color: Colors.grey.shade500)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showAddMenuDialog(context, data),
              child: const Text('Add Menu for this day'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: mealsForDay.length,
      itemBuilder: (context, index) {
        final menu = mealsForDay[index];
        return _MenuDayCard(
          menu: menu,
          onEdit: () => _showEditMenuDialog(context, data, menu),
          onDelete: () => data.deleteMealMenu(menu.id),
        );
      },
    );
  }

  void _showAddMenuDialog(BuildContext context, DataProvider data) {
    final breakfastCtrl = TextEditingController();
    final lunchCtrl = TextEditingController();
    final snacksCtrl = TextEditingController();
    final dinnerCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add $_currentFoodType Menu — $_selectedDay'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _currentFoodType == 'Vegetarian'
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _currentFoodType == 'Vegetarian'
                            ? Icons.eco
                            : Icons.restaurant,
                        size: 16,
                        color: _currentFoodType == 'Vegetarian'
                            ? Colors.green
                            : Colors.deepOrange,
                      ),
                      const SizedBox(width: 6),
                      Text(_currentFoodType,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _currentFoodType == 'Vegetarian'
                                ? Colors.green
                                : Colors.deepOrange,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: breakfastCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Breakfast',
                    prefixIcon: Icon(Icons.free_breakfast),
                    hintText: 'e.g. Idli, Sambar, Coffee',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lunchCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Lunch',
                    prefixIcon: Icon(Icons.lunch_dining),
                    hintText: 'e.g. Rice, Dal, Sabzi',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: snacksCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Snacks',
                    prefixIcon: Icon(Icons.cookie),
                    hintText: 'e.g. Tea, Biscuits',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dinnerCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Dinner',
                    prefixIcon: Icon(Icons.dinner_dining),
                    hintText: 'e.g. Chapati, Paneer, Rice',
                  ),
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
              final meal = MealMenu(
                id: '',
                day: _selectedDay,
                foodType: _currentFoodType,
                breakfast: breakfastCtrl.text.trim(),
                lunch: lunchCtrl.text.trim(),
                snacks: snacksCtrl.text.trim(),
                dinner: dinnerCtrl.text.trim(),
                weekStartDate: DateTime.now(),
                createdAt: DateTime.now(),
              );
              await data.addMealMenu(meal);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditMenuDialog(
      BuildContext context, DataProvider data, MealMenu menu) {
    final breakfastCtrl = TextEditingController(text: menu.breakfast);
    final lunchCtrl = TextEditingController(text: menu.lunch);
    final snacksCtrl = TextEditingController(text: menu.snacks);
    final dinnerCtrl = TextEditingController(text: menu.dinner);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${menu.foodType} Menu — ${menu.day}'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: menu.foodType == 'Vegetarian'
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        menu.foodType == 'Vegetarian'
                            ? Icons.eco
                            : Icons.restaurant,
                        size: 16,
                        color: menu.foodType == 'Vegetarian'
                            ? Colors.green
                            : Colors.deepOrange,
                      ),
                      const SizedBox(width: 6),
                      Text(menu.foodType,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: menu.foodType == 'Vegetarian'
                                ? Colors.green
                                : Colors.deepOrange,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: breakfastCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Breakfast',
                    prefixIcon: Icon(Icons.free_breakfast),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lunchCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Lunch',
                    prefixIcon: Icon(Icons.lunch_dining),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: snacksCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Snacks',
                    prefixIcon: Icon(Icons.cookie),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dinnerCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Dinner',
                    prefixIcon: Icon(Icons.dinner_dining),
                  ),
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
              await data.updateMealMenu(menu.id, {
                'breakfast': breakfastCtrl.text.trim(),
                'lunch': lunchCtrl.text.trim(),
                'snacks': snacksCtrl.text.trim(),
                'dinner': dinnerCtrl.text.trim(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── POLLS ──
  // ═══════════════════════════════════════════

  Widget _buildPollsList(DataProvider data) {
    final polls = data.polls;
    if (polls.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.poll, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text('No polls yet',
                style: TextStyle(color: Colors.grey.shade500)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showCreatePollDialog(context, data),
              icon: const Icon(Icons.add),
              label: const Text('Create your first poll'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: polls.length,
      itemBuilder: (context, index) {
        final poll = polls[index];
        return _WardenPollCard(
          poll: poll,
          students: data.students,
          onClose: () => data.closePollAndApply(poll.id),
          onDelete: () => data.deletePoll(poll.id),
        );
      },
    );
  }

  void _showCreatePollDialog(BuildContext context, DataProvider data) {
    final titleCtrl = TextEditingController();
    final optionCtrls = [TextEditingController(), TextEditingController()];
    String mealType = 'Breakfast';
    String targetDay = AppConstants.daysOfWeek[DateTime.now().weekday - 1];
    String foodType = 'Both';
    int durationHours = 2;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.poll, color: Colors.indigo),
              SizedBox(width: 8),
              Text('Create Meal Poll'),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Poll Title',
                      hintText: 'e.g. Vote for Friday Dinner',
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: mealType,
                          decoration: const InputDecoration(
                            labelText: 'Meal Type',
                            prefixIcon: Icon(Icons.restaurant_menu),
                          ),
                          items: ['Breakfast', 'Lunch', 'Snack', 'Dinner']
                              .map((e) => DropdownMenuItem(
                                  value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) =>
                              setDialogState(() => mealType = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: targetDay,
                          decoration: const InputDecoration(
                            labelText: 'Target Day',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          items: AppConstants.daysOfWeek
                              .map((e) => DropdownMenuItem(
                                  value: e, child: Text(e)))
                              .toList(),
                          onChanged: (v) =>
                              setDialogState(() => targetDay = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: foodType,
                    decoration: const InputDecoration(
                      labelText: 'Food Type',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: ['Both', 'Vegetarian', 'Non-Vegetarian']
                        .map((e) =>
                            DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => foodType = v!),
                  ),
                  const SizedBox(height: 20),
                  const Text('Options (min 2, max 4)',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...List.generate(optionCtrls.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: optionCtrls[i],
                              decoration: InputDecoration(
                                labelText: 'Option ${i + 1}',
                                hintText: 'e.g. Biryani',
                                prefixIcon:
                                    const Icon(Icons.circle, size: 12),
                              ),
                            ),
                          ),
                          if (optionCtrls.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red, size: 20),
                              onPressed: () {
                                setDialogState(() {
                                  optionCtrls.removeAt(i);
                                });
                              },
                            ),
                        ],
                      ),
                    );
                  }),
                  if (optionCtrls.length < 4)
                    TextButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          optionCtrls.add(TextEditingController());
                        });
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Option'),
                    ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: durationHours,
                    decoration: const InputDecoration(
                      labelText: 'Poll Duration',
                      prefixIcon: Icon(Icons.timer),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('1 hour')),
                      DropdownMenuItem(value: 2, child: Text('2 hours')),
                      DropdownMenuItem(value: 3, child: Text('3 hours')),
                      DropdownMenuItem(value: 4, child: Text('4 hours')),
                      DropdownMenuItem(value: 6, child: Text('6 hours')),
                      DropdownMenuItem(value: 8, child: Text('8 hours')),
                      DropdownMenuItem(value: 12, child: Text('12 hours')),
                      DropdownMenuItem(value: 24, child: Text('24 hours')),
                    ],
                    onChanged: (v) => setDialogState(() => durationHours = v!),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final opts = optionCtrls
                    .map((c) => c.text.trim())
                    .where((t) => t.isNotEmpty)
                    .toList();
                if (title.isEmpty || opts.length < 2) return;

                final now = DateTime.now();
                final poll = MealPoll(
                  id: '',
                  title: title,
                  mealType: mealType,
                  targetDay: targetDay,
                  foodType: foodType,
                  options:
                      opts.map((o) => PollOption(name: o, votes: 0)).toList(),
                  voters: {},
                  status: 'active',
                  createdAt: now,
                  expiresAt: now.add(Duration(hours: durationHours)),
                );
                await data.createPoll(poll);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Publish Poll'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuDayCard extends StatelessWidget {
  final MealMenu menu;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _MenuDayCard(
      {required this.menu, required this.onEdit, required this.onDelete});

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
                Icon(
                  menu.foodType == 'Vegetarian' ? Icons.eco : Icons.restaurant,
                  size: 18,
                  color: menu.foodType == 'Vegetarian'
                      ? Colors.green
                      : Colors.deepOrange,
                ),
                const SizedBox(width: 6),
                Text(menu.day,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: menu.foodType == 'Vegetarian'
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    menu.foodType,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: menu.foodType == 'Vegetarian'
                          ? Colors.green
                          : Colors.deepOrange,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
                IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: onDelete),
              ],
            ),
            const Divider(),
            _MealRow(
                icon: Icons.free_breakfast,
                label: 'Breakfast',
                value: menu.breakfast,
                color: Colors.orange),
            const SizedBox(height: 8),
            _MealRow(
                icon: Icons.lunch_dining,
                label: 'Lunch',
                value: menu.lunch,
                color: Colors.green),
            const SizedBox(height: 8),
            _MealRow(
                icon: Icons.cookie,
                label: 'Snacks',
                value: menu.snacks,
                color: Colors.purple),
            const SizedBox(height: 8),
            _MealRow(
                icon: Icons.dinner_dining,
                label: 'Dinner',
                value: menu.dinner,
                color: Colors.indigo),
          ],
        ),
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _MealRow(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: color, fontSize: 13)),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style:
                TextStyle(color: value.isEmpty ? Colors.grey : Colors.black87),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════
// ── WARDEN POLL CARD ──
// ═══════════════════════════════════════════

class _WardenPollCard extends StatelessWidget {
  final MealPoll poll;
  final List<dynamic> students;
  final VoidCallback onClose;
  final VoidCallback onDelete;
  const _WardenPollCard({
    required this.poll,
    required this.students,
    required this.onClose,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = poll.isActive;
    final isExpired = poll.isExpired && poll.status == 'active';
    final isClosed = poll.status == 'closed';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive
              ? Colors.indigo.shade200
              : isClosed
                  ? Colors.grey.shade300
                  : Colors.orange.shade200,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row ──
            Row(
              children: [
                Icon(Icons.poll,
                    color: isActive ? Colors.indigo : Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(poll.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                _statusBadge(isActive, isExpired, isClosed),
              ],
            ),
            const SizedBox(height: 8),

            // ── Meta: Day, MealType, FoodType ──
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _chip(Icons.calendar_today, poll.targetDay, Colors.blue),
                _chip(Icons.restaurant_menu, poll.mealType, Colors.orange),
                _chip(Icons.category, poll.foodType, Colors.purple),
              ],
            ),
            const SizedBox(height: 12),

            // ── Options with bar chart ──
            ...List.generate(poll.options.length, (i) {
              final opt = poll.options[i];
              final pct =
                  poll.totalVotes > 0 ? opt.votes / poll.totalVotes : 0.0;
              final isWinner = isClosed && poll.winner == opt.name;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isWinner)
                          const Icon(Icons.emoji_events,
                              color: Colors.amber, size: 16),
                        if (isWinner) const SizedBox(width: 4),
                        Expanded(
                          child: Text(opt.name,
                              style: TextStyle(
                                fontWeight: isWinner
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              )),
                        ),
                        Text('${opt.votes} votes',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                          isWinner ? Colors.amber : Colors.indigo.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),

            // ── Total Votes & Timer ──
            Row(
              children: [
                Text('${poll.totalVotes} total votes',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const Spacer(),
                if (isActive) _timerText(),
                if (isClosed && poll.appliedToMenu)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text('Applied to menu',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Voter List (warden can see who voted) ──
            if (poll.voters.isNotEmpty) ...[
              const Divider(),
              const Text('Voters',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: poll.voters.entries.map((entry) {
                  final optName = entry.value < poll.options.length
                      ? poll.options[entry.value].name
                      : '?';
                  return Chip(
                    visualDensity: VisualDensity.compact,
                    avatar: const Icon(Icons.person, size: 14),
                    label: Text(
                      '${_getStudentName(entry.key)} → $optName',
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                }).toList(),
              ),
            ],
            const Divider(),

            // ── Actions ──
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isActive || isExpired)
                  TextButton.icon(
                    onPressed: onClose,
                    icon: const Icon(Icons.stop_circle,
                        size: 18, color: Colors.orange),
                    label: const Text('Close & Apply',
                        style: TextStyle(color: Colors.orange)),
                  ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(bool isActive, bool isExpired, bool isClosed) {
    if (isClosed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Closed',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey)),
      );
    }
    if (isExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('Expired',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.orange)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Active',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.green)),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _timerText() {
    final remaining = poll.expiresAt.difference(DateTime.now());
    if (remaining.isNegative) {
      return const Text('Time up!',
          style: TextStyle(fontSize: 12, color: Colors.red));
    }
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final label = h >= 24 ? '${h ~/ 24}d ${h % 24}h left' : '${h}h ${m}m left';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer, size: 14, color: Colors.indigo),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.indigo)),
      ],
    );
  }

  String _getStudentName(String studentId) {
    try {
      final student = students.firstWhere((s) => s.uid == studentId);
      return student.name;
    } catch (_) {
      return studentId.substring(0, 6);
    }
  }
}
