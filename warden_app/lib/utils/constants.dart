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
  static const String mealPollsCollection = 'meal_polls';
  static const String announcementsCollection = 'announcements';
  static const String attendanceCollection = 'attendance';
  static const String gatePassCollection = 'gate_passes';
  static const String gateLogsCollection = 'gate_logs';
  static const String blocksCollection = 'blocks';

  static const List<String> complaintCategories = [
    'Maintenance',
    'AC',
    'Carpentry',
    'Electrical',
    'Plumbing',
  ];

  static const Map<String, List<String>> complaintSubCategories = {
    'Maintenance': ['Room Cleaning', 'RestRoom Cleaning', 'Civil Works'],
    'AC': ['Leakage Problem', 'Slow Cooling', 'Remote', 'Not Working'],
    'Carpentry': [
      'CupBoard',
      'Door',
      'CupBoard Mirror',
      'Bathroom Mirror',
      'Mosquito Mesh',
      'Cot',
      'Chair',
      'Study Table',
      'Book Shelf',
      'Door Frame',
      'Bathroom Hanger',
      'Towel Stand',
      'Soap Stand',
      'Curtain',
      'Table',
      'Others',
    ],
    'Electrical': [
      'Tubelight',
      'Fans',
      'Study Table Light',
      'Switches',
      'Sockets',
      'Others',
    ],
    'Plumbing': [
      'FlushTank',
      'Faucet',
      'Wash Basin',
      'Tap',
      'Shower',
      'Water Blockages',
      'Others',
    ],
  };

  static const List<String> urgencyLevels = ['Basic', 'Medium', 'Critical'];

  static const List<String> complaintStatuses = [
    'Pending',
    'Processing',
    'Fixed',
  ];

  static const List<String> leaveTypes = [
    'Home',
    'Medical',
    'Personal',
    'Emergency',
    'Academic',
  ];

  static const List<String> hostelBlocks = [
    'Block A',
    'Block B',
    'Block C',
    'Block D',
  ];

  static const List<int> roomSharingOptions = [2, 3, 4];

  static const List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
}
