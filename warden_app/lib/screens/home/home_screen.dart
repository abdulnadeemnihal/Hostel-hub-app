import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../students/students_screen.dart';
import '../complaints/complaints_screen.dart';
import '../leave/leave_screen.dart';
import '../rooms/rooms_screen.dart';
import '../attendance/attendance_screen.dart';
import '../gate_pass/gate_pass_screen.dart';
import '../mess/mess_screen.dart';
import '../announcements/announcements_screen.dart';
import '../fees/fees_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const _destinations = <NavigationRailDestination>[
    NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
    NavigationRailDestination(icon: Icon(Icons.people), label: Text('Students')),
    NavigationRailDestination(icon: Icon(Icons.report_problem), label: Text('Complaints')),
    NavigationRailDestination(icon: Icon(Icons.event_note), label: Text('Leave')),
    NavigationRailDestination(icon: Icon(Icons.bed), label: Text('Rooms')),
    NavigationRailDestination(icon: Icon(Icons.fact_check), label: Text('Attendance')),
    NavigationRailDestination(icon: Icon(Icons.qr_code_2), label: Text('Gate Pass')),
    NavigationRailDestination(icon: Icon(Icons.restaurant_menu), label: Text('Mess')),
    NavigationRailDestination(icon: Icon(Icons.campaign), label: Text('Announcements')),
    NavigationRailDestination(icon: Icon(Icons.receipt_long), label: Text('Fees')),
  ];

  static const _screens = <Widget>[
    DashboardScreen(),
    StudentsScreen(),
    ComplaintsScreen(),
    LeaveScreen(),
    RoomsScreen(),
    AttendanceScreen(),
    GatePassScreen(),
    MessScreen(),
    AnnouncementsScreen(),
    FeesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(children: [
                Icon(Icons.shield_rounded,
                    color: Theme.of(context).colorScheme.onPrimary, size: 32),
                const SizedBox(height: 4),
                Text('Warden',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ]),
            ),
            destinations: _destinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}
