import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../models/meal_model.dart';
import '../../utils/constants.dart';

class MessScreen extends StatefulWidget {
  const MessScreen({super.key});

  @override
  State<MessScreen> createState() => _MessScreenState();
}

class _MessScreenState extends State<MessScreen> {
  String _selectedDay = AppConstants.daysOfWeek[DateTime.now().weekday - 1];

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final mealsForDay = data.meals.where((m) => m.day == _selectedDay).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Mess Menu Management',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddMenuDialog(context, data),
                icon: const Icon(Icons.add),
                label: const Text('Add Menu'),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          Expanded(
            child: mealsForDay.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text('No menu for $_selectedDay',
                            style: TextStyle(color: Colors.grey.shade500)),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _showAddMenuDialog(context, data),
                          child: const Text('Add Menu for this day'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: mealsForDay.length,
                    itemBuilder: (context, index) {
                      final menu = mealsForDay[index];
                      return _MenuDayCard(
                        menu: menu,
                        onEdit: () => _showEditMenuDialog(context, data, menu),
                        onDelete: () => data.deleteMealMenu(menu.id),
                      );
                    },
                  ),
          ),
        ],
      ),
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
        title: Text('Add Menu for $_selectedDay'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final meal = MealMenu(
                id: '',
                day: _selectedDay,
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

  void _showEditMenuDialog(BuildContext context, DataProvider data, MealMenu menu) {
    final breakfastCtrl = TextEditingController(text: menu.breakfast);
    final lunchCtrl = TextEditingController(text: menu.lunch);
    final snacksCtrl = TextEditingController(text: menu.snacks);
    final dinnerCtrl = TextEditingController(text: menu.dinner);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Menu - ${menu.day}'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
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
}

class _MenuDayCard extends StatelessWidget {
  final MealMenu menu;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _MenuDayCard({required this.menu, required this.onEdit, required this.onDelete});

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
                Text(menu.day,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
                IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: onDelete),
              ],
            ),
            const Divider(),
            _MealRow(icon: Icons.free_breakfast, label: 'Breakfast', value: menu.breakfast, color: Colors.orange),
            const SizedBox(height: 8),
            _MealRow(icon: Icons.lunch_dining, label: 'Lunch', value: menu.lunch, color: Colors.green),
            const SizedBox(height: 8),
            _MealRow(icon: Icons.cookie, label: 'Snacks', value: menu.snacks, color: Colors.purple),
            const SizedBox(height: 8),
            _MealRow(icon: Icons.dinner_dining, label: 'Dinner', value: menu.dinner, color: Colors.indigo),
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
  const _MealRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: TextStyle(color: value.isEmpty ? Colors.grey : Colors.black87),
          ),
        ),
      ],
    );
  }
}
