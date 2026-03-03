class AppConstants {
  static const String appName = 'Hostel Warden';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String studentsCollection = 'students';
  static const String wardensCollection = 'wardens';
  static const String complaintsCollection = 'complaints';
  static const String leaveCollection = 'leave_applications';
  static const String roomsCollection = 'rooms';
  static const String feesCollection = 'fees';
  static const String mealsCollection = 'meal_menus';
  static const String mealPreferencesCollection = 'meal_preferences';
  static const String announcementsCollection = 'announcements';
  static const String attendanceCollection = 'attendance';
  static const String gatePassCollection = 'gate_passes';

  static const List<String> complaintCategories = [
    'Maintenance', 'Cleanliness', 'Security', 'Food Quality',
    'Electrical', 'Plumbing', 'Furniture', 'Other',
  ];

  static const List<String> leaveTypes = [
    'Home', 'Medical', 'Personal', 'Emergency', 'Academic',
  ];

  static const List<String> hostelBlocks = [
    'Block A', 'Block B', 'Block C', 'Block D',
  ];

  static const List<String> daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
}
