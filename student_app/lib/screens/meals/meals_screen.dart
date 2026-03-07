import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../utils/constants.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final auth = context.watch<AuthProvider>();
    final foodPref = auth.student?.foodPreference ?? 'Vegetarian';
    final isVeg = foodPref == 'Vegetarian';

    // Sort menus by day-of-week order (Mon→Sun)
    final sortedMenus = List.of(data.mealMenus);
    sortedMenus.sort((a, b) {
      final ai = AppConstants.daysOfWeek.indexOf(a.day);
      final bi = AppConstants.daysOfWeek.indexOf(b.day);
      return ai.compareTo(bi);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Mess Menu')),
      body: Column(
        children: [
          // ── Food Preference Banner ──
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isVeg ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isVeg ? Colors.green.shade200 : Colors.orange.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isVeg ? Icons.eco : Icons.restaurant,
                  color: isVeg ? Colors.green : Colors.deepOrange,
                ),
                const SizedBox(width: 10),
                Text(
                  isVeg ? 'Vegetarian Menu' : 'Non-Vegetarian Menu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isVeg ? Colors.green.shade800 : Colors.deepOrange.shade800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isVeg ? Colors.green.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '7-Day Plan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isVeg ? Colors.green.shade700 : Colors.deepOrange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Menu Content ──
          Expanded(
            child: sortedMenus.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('No menu available',
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text('Menu will be updated by warden',
                            style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Weekly Menu',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ...sortedMenus.map((menu) => _MealDayCard(menu: menu)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MealDayCard extends StatelessWidget {
  final dynamic menu;
  const _MealDayCard({required this.menu});

  @override
  Widget build(BuildContext context) {
    final isToday = menu.day.toLowerCase() ==
        AppConstants.daysOfWeek[DateTime.now().weekday - 1].toLowerCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isToday ? Colors.deepOrange.shade50 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isToday
            ? BorderSide(color: Colors.deepOrange.shade200, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  menu.day,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.deepOrange : null,
                  ),
                ),
                if (isToday)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('TODAY',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _MealRow(icon: Icons.wb_sunny, label: 'Breakfast', value: menu.breakfast),
            _MealRow(icon: Icons.restaurant, label: 'Lunch', value: menu.lunch),
            _MealRow(icon: Icons.cookie, label: 'Snacks', value: menu.snacks),
            _MealRow(icon: Icons.nightlight, label: 'Dinner', value: menu.dinner),
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
  const _MealRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.deepOrange.shade300),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(label,
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700])),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
