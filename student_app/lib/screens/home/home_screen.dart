import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../announcements/announcements_screen.dart';
import '../attendance/attendance_screen.dart';
import '../complaints/complaints_screen.dart';
import '../fees/fees_screen.dart';
import '../gate_pass/gate_pass_screen.dart';
import '../leave/leave_screen.dart';
import '../meals/meals_screen.dart';
import '../profile/profile_screen.dart';
import '../room/room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.student != null) {
      context.read<DataProvider>().loadStudentData(auth.student!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _HomeTab(onNavigate: _navigate),
          const _NotificationsTab(),
          const _SupportTab(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (i) => setState(() => _currentTab = i),
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor: const Color(0xFF4F46E5).withValues(alpha: 0.1),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Color(0xFF4F46E5)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications, color: Color(0xFF4F46E5)),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.support_agent_outlined),
            selectedIcon: Icon(Icons.support_agent, color: Color(0xFF4F46E5)),
            label: 'Support',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Color(0xFF4F46E5)),
            label: 'My Profile',
          ),
        ],
      ),
    );
  }

  void _navigate(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

// ─── Home Tab ───
class _HomeTab extends StatelessWidget {
  final void Function(Widget) onNavigate;
  const _HomeTab({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final student = auth.student;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting Header ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${student?.name ?? 'Student'} 👋',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E2D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        student?.roomNumber != null && student!.roomNumber.isNotEmpty
                            ? 'Room ${student.roomNumber} • ${student.hostelBlock}'
                            : student?.department ?? 'Welcome back!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF4F46E5),
                  child: Text(
                    (student?.name ?? 'S')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Quick Actions ──
            _SectionCard(
              title: 'Quick Actions',
              child: Wrap(
                spacing: 16,
                runSpacing: 20,
                children: [
                  _QuickActionItem(
                    emoji: '📅',
                    label: 'Apply\nLeave',
                    onTap: () => onNavigate(const LeaveScreen()),
                  ),
                  _QuickActionItem(
                    emoji: '🔧',
                    label: 'Raise\nTicket',
                    onTap: () => onNavigate(const ComplaintsScreen()),
                  ),
                  _QuickActionItem(
                    emoji: '🍽️',
                    label: 'Book a\nMeal',
                    onTap: () => onNavigate(const MealsScreen()),
                  ),
                  _QuickActionItem(
                    emoji: '💳',
                    label: 'Pay\nFee',
                    onTap: () => onNavigate(const FeesScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Apps ──
            _SectionCard(
              title: 'Apps',
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: [
                  _AppTile(
                    icon: Icons.event_note_rounded,
                    label: 'Leave\nManager',
                    color: const Color(0xFF4F46E5),
                    onTap: () => onNavigate(const LeaveScreen()),
                  ),
                  _AppTile(
                    icon: Icons.confirmation_number_rounded,
                    label: 'Tickets',
                    color: const Color(0xFF7C3AED),
                    onTap: () => onNavigate(const ComplaintsScreen()),
                  ),
                  _AppTile(
                    icon: Icons.campaign_rounded,
                    label: 'Announce-\nments',
                    color: const Color(0xFF4F46E5),
                    onTap: () => onNavigate(const AnnouncementsScreen()),
                  ),
                  _AppTile(
                    icon: Icons.restaurant_rounded,
                    label: 'Mess\nManager',
                    color: const Color(0xFF0D9488),
                    onTap: () => onNavigate(const MealsScreen()),
                  ),
                  _AppTile(
                    icon: Icons.fact_check_rounded,
                    label: 'Attendance',
                    color: const Color(0xFF6366F1),
                    onTap: () => onNavigate(const AttendanceScreen()),
                  ),
                  _AppTile(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Finance',
                    color: const Color(0xFF2563EB),
                    onTap: () => onNavigate(const FeesScreen()),
                  ),
                  _AppTile(
                    icon: Icons.bed_rounded,
                    label: 'My Room',
                    color: const Color(0xFF0891B2),
                    onTap: () => onNavigate(const RoomScreen()),
                  ),
                  _AppTile(
                    icon: Icons.badge_rounded,
                    label: 'Gate Pass',
                    color: const Color(0xFF9333EA),
                    onTap: () => onNavigate(const GatePassScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Section Card ───
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D))),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

// ─── Quick Action Item (emoji style) ───
class _QuickActionItem extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _QuickActionItem({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EFFA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E1E2D))),
          ],
        ),
      ),
    );
  }
}

// ─── App Tile (icon with colored bg) ───
class _AppTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AppTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E1E2D))),
        ],
      ),
    );
  }
}

// ─── Notifications Tab (placeholder) ───
class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No notifications yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Support Tab (placeholder) ───
class _SupportTab extends StatelessWidget {
  const _SupportTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Support',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const ListTile(
                leading: Icon(Icons.email_outlined, color: Color(0xFF4F46E5)),
                title: Text('Email Support'),
                subtitle: Text('hostel.support@college.edu'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const ListTile(
                leading: Icon(Icons.phone_outlined, color: Color(0xFF4F46E5)),
                title: Text('Call Warden'),
                subtitle: Text('Contact the hostel warden'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: const Icon(Icons.report_problem_outlined, color: Color(0xFF4F46E5)),
                title: const Text('Raise a Complaint'),
                subtitle: const Text('Report an issue'),
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const ComplaintsScreen())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
